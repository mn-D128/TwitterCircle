//
//  AccountListViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import TwitterKit
import Result
import SwiftyUserDefaults

class AccountListViewModel: BaseViewModel {

    private let items: Variable<[SessionDto]> = Variable<[SessionDto]>([])
    lazy var itemsObservable: Observable<[SessionDto]> = {
        return self.items.asObservable()
    }()

    private let sessionLocalRepos: SessionLocalRepository
    private let userRepos: UserRepository
    private let userLocalRepos: UserLocalRepository
    private let friendLocalRepos: FriendLocalRepository
    private let historyLocalRepos: HistoryLocalRepository

    private let disposeBag: DisposeBag = DisposeBag()

    init(sessionLocalRepos: SessionLocalRepository,
         friendLocalRepos: FriendLocalRepository,
         historyLocalRepos: HistoryLocalRepository,
         userRepos: UserRepository,
         userLocalRepos: UserLocalRepository) {
        self.sessionLocalRepos = sessionLocalRepos
        self.friendLocalRepos = friendLocalRepos
        self.historyLocalRepos = historyLocalRepos
        self.userRepos = userRepos
        self.userLocalRepos = userLocalRepos

        super.init()

        self.updateItems()
    }

    // MARK: - Private

    private func updateItems() {
        self.items.value = self.sessionLocalRepos.findAll()
    }

    private func loadUser(_ session: BaseSessionDto) {
        let completion: (Result<UserDto, ResponseError>) -> Void = { [weak self] (result: Result<UserDto, ResponseError>) in
            guard let weakSelf: AccountListViewModel = self else {
                return
            }

            weakSelf.setProgressHidden(true)

            switch result {
            case Result.success(let user):
                // TODO: 返却値
                weakSelf.sessionLocalRepos
                    .append(SessionDto(baseSession: session,
                                       user: user))
                weakSelf.updateItems()

            case Result.failure(let error):
                sLogger?.error(error)

                switch error as ResponseError {
                case ResponseError.loginFailed(_): break
                case ResponseError.mismatchParameter(_): break
                case ResponseError.requestFaild(let error):
                    let error: NSError = error as NSError
                    weakSelf.setToastErrorMessage(error.localizedDescription)

                case ResponseError.parseFailed: break
                case ResponseError.rateLimitExceeded:
                    weakSelf.setToastErrorMessage("TWITTER_API_RATELIMITEXCEEDED".localized)

                case ResponseError.invalidOrExpiredToken:
                    weakSelf.setToastErrorMessage("TWITTER_API_INVALID_OR_EXPIREDTOKEN".localized)
                }
            }
        }

        self.setProgressHidden(false)

        self.userRepos
            .find(session: session,
                  userID: session.userID,
                  completion: completion)
            .disposed(by: self.disposeBag)
    }

    // MARK: - Public

    func viewWillAppear() {
        if 0 < self.items.value.count {
            return
        }

        self.updateItems()
    }

    func addAcount() {
        let completion: (BaseSessionDto?, Error?) -> Void = { [weak self] (session: BaseSessionDto?, error: Error?) in
            if let session = session {
                self?.loadUser(session)
            }
            // TODO: エラー処理
//            else if let error: Error = error {
//                let err = error as NSError
//                guard let code: TwitterKitLoginErrorCode = TwitterKitLoginErrorCode(rawValue: err.code) else {
//                    return
//                }
//
//                switch code {
//                case .cancelled: break
//                case .cannotRefreshSession: break
//                case .denied: break
//                case .failed: break
//                case .noAccounts: break
//                case .noTwitterApp: break
//                case .reverseAuthFailed: break
//                case .sessionNotFound: break
//                case .systemAccountCredentialsInvalid: break
//                case .unknown: break
//                }
//            }
        }

        TwitterKitManager.shared.logIn(completion)
    }

    func deleteAccount(_ session: SessionDto) {
        guard self.historyLocalRepos.deleteAll(session.userID) == nil else {
            return
        }

        guard self.friendLocalRepos.deleteAll(session.userID) == nil else {
            return
        }

        guard self.sessionLocalRepos.delete(session) == nil else {
            return
        }

        let sessions: [SessionDto] = self.sessionLocalRepos.findAll()

        let selectedUserID: String? = Defaults[DefaultsKeys.selectedUserID]
        if session.userID == selectedUserID {
            if let firstSession: SessionDto = sessions.first {
                Defaults[DefaultsKeys.selectedUserID] = firstSession.userID
            } else {
                Defaults[DefaultsKeys.selectedUserID] = nil
            }
        }

        self.items.value = sessions
    }

    func selectAccount(_ session: SessionDto) {
        Defaults[DefaultsKeys.selectedUserID] = session.userID

        // リロードを促す
        let sessions: [SessionDto] = self.items.value
        self.items.value = sessions
    }

}

extension SessionDto {

    var isSelected: Bool {
        let selectedUserID: String? = Defaults[DefaultsKeys.selectedUserID]
        return selectedUserID == self.userID
    }

}
