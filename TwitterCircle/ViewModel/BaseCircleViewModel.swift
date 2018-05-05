//
//  CircleViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Result
import SwiftyUserDefaults

class BaseCircleViewModel: BaseViewModel {

    private let sessionLocalRepos: SessionLocalRepository
    private let userTimelineRepos: UserTimelineRepository
    private let tweetLocalRepos: TweetLocalRepository

    private var disposeBag: DisposeBag = DisposeBag()

    var session: SessionDto?

    private var isActive: Bool = false

    private let dateVariable: Variable<CircleDate> = Variable<CircleDate>(CircleDate.now)
    lazy var dateDriver: SharedSequence = {
        return self.dateVariable.asDriver()
    }()

    private let tweetsVariable: Variable<[TweetDto]?> = Variable<[TweetDto]?>(nil)
    lazy var tweetsDriver: SharedSequence = {
        return self.tweetsVariable.asDriver().filterNil()
    }()
    lazy var tweetsObservable: Observable<[TweetDto]> = {
        return self.tweetsVariable.asObservable().filterNil()
    }()

    private let userVariable: Variable<UserDto?> = Variable<UserDto?>(nil)
    lazy var userDriver: SharedSequence = {
        return self.userVariable.asDriver().filterNil()
    }()

    init(sessionLocalRepos: SessionLocalRepository,
         userTimelineRepos: UserTimelineRepository,
         tweetLocalRepos: TweetLocalRepository) {
        self.sessionLocalRepos = sessionLocalRepos
        self.userTimelineRepos = userTimelineRepos
        self.tweetLocalRepos = tweetLocalRepos

        super.init()

        if let selectedUserID: String = Defaults[DefaultsKeys.selectedUserID] {
            self.session = self.sessionLocalRepos.find(userID: selectedUserID)
        }

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(userDefaultsDidChange(_:)),
                         name: UserDefaults.didChangeNotification,
                         object: nil)
    }

    deinit {
        NotificationCenter.default
            .removeObserver(self)
    }

    // MARK: - Public

    func viewWillAppear() {
        self.isActive = true

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: .UIApplicationWillEnterForeground,
                         object: nil)

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(applicationDidEnterBackground(_:)),
                         name: .UIApplicationDidEnterBackground,
                         object: nil)

        self.loadIfNeeded()?.disposed(by: self.disposeBag)
    }

    func viewWillDisappear() {
        self.isActive = false

        NotificationCenter.default
            .removeObserver(self,
                            name: .UIApplicationWillEnterForeground,
                            object: nil)

        NotificationCenter.default
            .removeObserver(self,
                            name: .UIApplicationDidEnterBackground,
                            object: nil)

        // クリア
        self.disposeBag = DisposeBag()
    }

    func previousDate() {
        guard let previousDate: CircleDate = self.dateVariable.value.previousDate else {
            sLogger?.error("previousDate nil")
            return
        }

        self.setDate(previousDate)
    }

    func nextDate() {
        guard let nextDate: CircleDate = self.dateVariable.value.nextDate else {
            sLogger?.error("nextDate nil")
            return
        }

        self.setDate(nextDate)
    }

    func setDate(_ date: CircleDate) {
        self.dateVariable.value = date
        self.tweetsVariable.value = [TweetDto]()

        self.loadIfNeeded()?.disposed(by: self.disposeBag)
    }

    func setUser(_ user: UserDto?) {
        self.userVariable.value = user

        if self.isActive {
            self.disposeBag = DisposeBag()
            self.loadIfNeeded()?.disposed(by: self.disposeBag)
        }
    }

    // MARK: - Private

    private func loadIfNeeded(_ emptyMaxID: Bool = false) -> Disposable? {
        let date: CircleDate = self.dateVariable.value
        guard let beginDate: Date = date.beginDate,
            let endDate: Date = date.endDate,
            let userID: String = self.userVariable.value?.idStr,
            let session: SessionDto = self.session else {
            return nil
        }

        var emptyMaxID: Bool = emptyMaxID

        let tweets: [TweetDto] = self.tweetLocalRepos.findAll(userID, fromDate: beginDate, toDate: endDate)

        var maxID: String?
        if let lastTweet: TweetDto = self.tweetLocalRepos.findLast(userID) {
            if let tweet: TweetDto = tweets.last {
                if lastTweet == tweet {
                    maxID = lastTweet.idStr
                }
            } else {
                let count: Int = self.tweetLocalRepos.count(userID, fromDate: nil, toDate: beginDate)
                if count == 0 {
                    maxID = lastTweet.idStr
                }
            }
        }

        var sinceID: String?
        if maxID == nil {
            if let firstTweet: TweetDto = self.tweetLocalRepos.findFirst(userID) {
                if let tweet: TweetDto = tweets.first {
                    if firstTweet == tweet {
                        sinceID = firstTweet.idStr
                    }
                } else {
                    let count: Int = self.tweetLocalRepos.count(userID, fromDate: endDate, toDate: nil)
                    if count == 0 {
                        sinceID = firstTweet.idStr
                    } else {
                        emptyMaxID = true
                    }
                }
            }
        }

        if maxID == nil && sinceID == nil && (0 < tweets.count || emptyMaxID) {
            let oldCount: Int = self.tweetsVariable.value?.count ?? 0
            if oldCount != tweets.count {
                self.tweetsVariable.value = tweets
            }

            self.setProgressHidden(true)
            return nil
        }

        return self.load(session: session, userID: userID, sinceID: sinceID, maxID: maxID)
    }

    private func load(session: SessionDto, userID: String, sinceID: String?, maxID: String?) -> Disposable? {
        let params: UserTimelineParams
            = UserTimelineParams(userID: userID,
                                 sinceID: sinceID,
                                 maxID: maxID,
                                 count: 200)

        let completion: (Result<[TweetDto], ResponseError>) -> Void = { [weak self] (result: Result<[TweetDto], ResponseError>) in
            guard let weakSelf: BaseCircleViewModel = self else {
                return
            }

            switch result {
            case Result.success(let tweets):
                weakSelf.loadDidSuccess(tweets, params: params)

            case Result.failure(let error):
                weakSelf.loadDidFailure(error)
            }
        }

        self.setProgressHidden(false)

        return self.userTimelineRepos
            .find(session: session,
                  params: params,
                  completion: completion)
    }

    private func loadDidSuccess(_ tweets: [TweetDto], params: UserTimelineParams) {
        var emptyMaxID: Bool = false

        if tweets.isEmpty {
            if params.sinceID != nil {
                let date: CircleDate = self.dateVariable.value
                guard let beginDate: Date = date.beginDate,
                    let endDate: Date = date.endDate else {
                    return
                }

                let tweets: [TweetDto] = self.tweetLocalRepos.findAll(params.userID,
                                                                      fromDate: beginDate,
                                                                      toDate: endDate)
                let oldCount: Int = self.tweetsVariable.value?.count ?? 0
                if oldCount != tweets.count {
                    self.tweetsVariable.value = tweets
                }

                self.setProgressHidden(true)
                return
            } else if params.maxID != nil {
                emptyMaxID = true
            }
        }

        self.tweetLocalRepos.append(contentsOf: tweets)

        self.loadIfNeeded(emptyMaxID)?.disposed(by: self.disposeBag)
    }

    private func loadDidFailure(_ error: ResponseError) {
        sLogger?.error(error)

        self.setProgressHidden(true)

        switch error as ResponseError {
        case ResponseError.loginFailed(_): break
        case ResponseError.mismatchParameter(_): break
        case ResponseError.parseFailed: break

        case ResponseError.requestFaild(let error):
            let error: NSError = error as NSError
            self.setToastErrorMessage(error.localizedDescription)
        case ResponseError.rateLimitExceeded:
            self.setToastErrorMessage("TWITTER_API_RATELIMITEXCEEDED".localized)
        case ResponseError.invalidOrExpiredToken:
            self.setToastErrorMessage("TWITTER_API_INVALID_OR_EXPIREDTOKEN".localized)
        }
    }

    // MARK: - NotificationCenter

    @objc private func userDefaultsDidChange(_ notification: Notification) {
        let selectedUserID: String? = Defaults[DefaultsKeys.selectedUserID]
        if self.session?.userID != selectedUserID {
            if let selectedUserID: String = selectedUserID {
                self.session = self.sessionLocalRepos.find(userID: selectedUserID)
            } else {
                self.session = nil
            }
        }
    }

    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        self.loadIfNeeded()?.disposed(by: self.disposeBag)
    }

    @objc private func applicationDidEnterBackground(_ notification: Notification) {
        self.disposeBag = DisposeBag()
    }

}
