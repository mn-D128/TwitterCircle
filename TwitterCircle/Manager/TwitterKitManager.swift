//
//  TwitterKitManager.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import TwitterKit

enum TwitterKitLoginErrorCode: Int {

    case unknown = -1
    case denied = 0
    case cancelled = 1
    case noAccounts = 2
    case reverseAuthFailed = 3
    case cannotRefreshSession = 4
    case sessionNotFound = 5
    case failed = 6
    case systemAccountCredentialsInvalid = 7
    case noTwitterApp = 8

}

class TwitterKitManager {

    static let shared: TwitterKitManager = TwitterKitManager()

    private init() {
    }

    // MARK: - Public

    func start(consumerKey: String, consumerSecret: String) {
        TWTRTwitter.sharedInstance()
            .start(withConsumerKey: consumerKey,
                   consumerSecret: consumerSecret)
    }

    func logIn(_ completion: @escaping (BaseSessionDto?, Error?) -> Void) {
        let completion: TWTRLogInCompletion = { (session: TWTRAuthSession?, error: Error?) in
            if let session: BaseSessionDto = session?.baseSessionDto {
                completion(session, nil)
            } else {
                completion(nil, error)
            }
        }

        TWTRTwitter.sharedInstance().logIn(completion: completion)
    }

}

extension TWTRAuthSession {

    var baseSessionDto: BaseSessionDto {
        return BaseSessionDto(authToken: self.authToken,
                              authTokenSecret: self.authTokenSecret,
                              userID: self.userID)
    }

}
