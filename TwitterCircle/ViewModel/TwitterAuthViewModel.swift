//
//  TwitterAuthViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import Result
import SwiftyUserDefaults

class TwitterAuthViewModel: BaseViewModel {

    private let sessionLocalRepos: SessionLocalRepository
    private let userRepos: UserRepository
    private let userLocalRepos: UserLocalRepository

    private let disposeBag: DisposeBag = DisposeBag()

    init(sessionLocalRepos: SessionLocalRepository,
         userRepos: UserRepository,
         userLocalRepos: UserLocalRepository) {
        self.sessionLocalRepos = sessionLocalRepos
        self.userRepos = userRepos
        self.userLocalRepos = userLocalRepos

        super.init()
    }

    // MARK: - Public

    func loginAcount() {
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

    // MARK: - Private

    private func loadUser(_ session: BaseSessionDto) {
        let completion: (Result<UserDto, ResponseError>) -> Void = { [weak self] (result: Result<UserDto, ResponseError>) in
            guard let weakSelf: TwitterAuthViewModel = self else {
                return
            }

            weakSelf.setProgressHidden(true)

            switch result {
            case Result.success(let user):
                let session: SessionDto = SessionDto(baseSession: session,
                                                     user: user)
                // TODO: 返却値
                weakSelf.sessionLocalRepos .append(session)
                Defaults[DefaultsKeys.selectedUserID] = session.userID

            case Result.failure(let error):
                sLogger?.error(error)

                switch error as ResponseError {
                case ResponseError.loginFailed(_): break
                case ResponseError.mismatchParameter(_): break
                case ResponseError.parseFailed: break

                case ResponseError.requestFaild(let error):
                    let error: NSError = error as NSError
                    weakSelf.setToastErrorMessage(error.localizedDescription)
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

}
