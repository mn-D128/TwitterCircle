//
//  FollowListViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/07.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Result
import SwiftyUserDefaults

class FollowListViewModel: BaseViewModel {

    private let items: Variable<[UserDto]> = Variable<[UserDto]>([])
    lazy var itemsObservable: Observable<[UserDto]> = {
        return self.items.asObservable()
    }()

    private let isEmptyHidden: Variable<Bool> = Variable<Bool>(true)
    lazy var isEmptyHiddenDriver: SharedSequence = {
        return self.isEmptyHidden.asDriver()
    }()

    private let isNoResultSearchHidden: Variable<Bool> = Variable<Bool>(true)
    lazy var isNoResultSearchHiddenDriver: SharedSequence = {
        return self.isNoResultSearchHidden.asDriver()
    }()

    private let hasNext: Variable<Bool> = Variable<Bool>(false)
    lazy var hasNextDriver: SharedSequence = {
        return self.hasNext.asDriver()
    }()

    private let sessionLocalRepos: SessionLocalRepository
    private let friendRepos: FriendRepository
    private let friendLocalRepos: FriendLocalRepository
    private let historyLocalRepos: HistoryLocalRepository

    private var isLoading: Bool = false
    private var isSearching: Bool = false
    private var canToastError: Bool = true

    private var disposeBag: DisposeBag = DisposeBag()

    private var search: String? {
        didSet {
            guard let session: SessionDto = self.session else {
                return
            }

            self.items.value = self.friendLocalRepos.findAll(session.userID, search: self.search)

            if self.isSearching {
                self.isNoResultSearchHidden.value = !self.items.value.isEmpty
            } else {
                self.isNoResultSearchHidden.value = true
            }
        }
    }

    private var session: SessionDto? {
        didSet {
            self.disposeBag = DisposeBag()
            self.isLoading = false
            self.setProgressHidden(true)

            self.updateDataSource()
        }
    }

    init(sessionLocalRepos: SessionLocalRepository,
         friendRepos: FriendRepository,
         friendLocalRepos: FriendLocalRepository,
         historyLocalRepos: HistoryLocalRepository) {
        self.sessionLocalRepos = sessionLocalRepos
        self.friendRepos = friendRepos
        self.friendLocalRepos = friendLocalRepos
        self.historyLocalRepos = historyLocalRepos

        super.init()

        if let selectedUserID: String = Defaults[DefaultsKeys.selectedUserID] {
            self.session = self.sessionLocalRepos.find(userID: selectedUserID)
        }

        self.updateDataSource()

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
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(applicationWillEnterForeground(_:)),
                         name: .UIApplicationWillEnterForeground,
                         object: nil)

        guard self.dataSourceCount() == 0 else {
            return
        }

        self.load()?.disposed(by: self.disposeBag)
    }

    func viewWillDisappear() {
        NotificationCenter.default
            .removeObserver(self,
                            name: .UIApplicationWillEnterForeground,
                            object: nil)
    }

    func loadNext() {
        self.load(true)?.disposed(by: self.disposeBag)
    }

    func selectUser(_ user: UserDto) {
        guard let session: SessionDto = self.session else {
            return
        }

        let history: HistoryDto = HistoryDto(userID: session.userID,
                                             user: user)

        self.historyLocalRepos.append(history)
    }

    func refresh() {
        guard let session: SessionDto = self.session else {
            return
        }

        self.friendLocalRepos.deleteAll(session.userID)
        self.session = session
        self.canToastError = true

        self.load()?.disposed(by: self.disposeBag)
    }

    // MARK: -

    func searchWillPresent() {
        self.isSearching = true
        self.hasNext.value = false
    }

    func search(_ text: String?) {
        if let text: String = text, 0 < text.utf8.count {
            self.search = text
        } else {
            self.search = nil
        }
    }

    func searchWillDismiss() {
        self.isSearching = false

        if let session: SessionDto = self.session {
            self.hasNext.value = 0 < self.friendLocalRepos.nextCursor(session.userID)
        }

        self.isNoResultSearchHidden.value = true
    }

    // MARK: - Private

    private func load(_ next: Bool = false) -> Disposable? {
        guard !self.isLoading,
            let session: SessionDto = self.session else {
            return nil
        }

        let completion: (Result<FriendResponseDto, ResponseError>) -> Void
            = { [weak self] (result: Result<FriendResponseDto, ResponseError>) in
            self?.loadDidComplete(selectedUserID: session.userID, result: result)
        }

        var nextCursor: Int?
        if next {
            nextCursor = self.friendLocalRepos.nextCursor(session.userID)
        } else {
            self.setProgressHidden(false)
            self.isEmptyHidden.value = true
        }

        self.isLoading = true

        sLogger?.verbose("\(nextCursor ?? 0)")

        return self.friendRepos
            .find(session: session,
                  cursor: nextCursor,
                  count: 200,
                  completion: completion)
    }

    private func loadDidComplete(selectedUserID: String, result: Result<FriendResponseDto, ResponseError>) {
        self.isLoading = false
        self.setProgressHidden(true)

        switch result {
        case Result.success(let response):
            // TODO: 返却値
            self.friendLocalRepos.append(userID: selectedUserID,
                                         users: response.users,
                                         nextCursor: response.nextCursor)

            sLogger?.verbose("response.nextCursor \(response.nextCursor)")

            self.canToastError = true
            self.items.value = self.friendLocalRepos.findAll(selectedUserID, search: self.search)
            self.isEmptyHidden.value = 0 < self.friendLocalRepos.count(selectedUserID)

            if self.isSearching {
                self.hasNext.value = false
                self.isNoResultSearchHidden.value = !self.items.value.isEmpty
            } else {
                self.hasNext.value = 0 < response.nextCursor
                self.isNoResultSearchHidden.value = true
            }

        case Result.failure(let error):
            self.isEmptyHidden.value = self.dataSourceCount() != 0

            sLogger?.error(error)
            switch error as ResponseError {
            case ResponseError.loginFailed(_): break
            case ResponseError.mismatchParameter(_): break
            case ResponseError.requestFaild(let error):
                let error: NSError = error as NSError
                self.setToastErrorMessage(error.localizedDescription)

            case ResponseError.parseFailed: break
            case ResponseError.rateLimitExceeded:
                self.setToastErrorMessage("TWITTER_API_RATELIMITEXCEEDED".localized)
            case ResponseError.invalidOrExpiredToken:
                self.setToastErrorMessage("TWITTER_API_INVALID_OR_EXPIREDTOKEN".localized)
            }

            self.canToastError = false
        }
    }

    override func setToastErrorMessage(_ message: String) {
        if self.canToastError {
            super.setToastErrorMessage(message)
        }
    }

    // MARK: -

    private func updateDataSource() {
        guard let session: SessionDto = self.session else {
            return
        }

        self.items.value = self.friendLocalRepos.findAll(session.userID, search: self.search)
        self.hasNext.value = 0 < self.friendLocalRepos.nextCursor(session.userID)
        self.isEmptyHidden.value = 0 < self.dataSourceCount()
        self.isNoResultSearchHidden.value = true
    }

    private func dataSourceCount() -> Int {
        guard let session: SessionDto = self.session else {
            return 0
        }

        return self.friendLocalRepos.count(session.userID)
    }

    // MARK: - NotificationCenter

    @objc private func userDefaultsDidChange(_ notification: Notification) {
        if let selectedUserID: String = Defaults[DefaultsKeys.selectedUserID] {
            if selectedUserID != self.session?.userID {
                self.session = self.sessionLocalRepos.find(userID: selectedUserID)
                self.search = nil
            }
        } else {
            self.session = nil
        }
    }

    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        guard self.dataSourceCount() == 0 else {
            return
        }

        self.load()?.disposed(by: self.disposeBag)
    }

}
