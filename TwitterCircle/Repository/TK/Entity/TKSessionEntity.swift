//
//  TKSessionEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import TwitterKit

class TKSessionEntity: NSObject, TWTRAuthSession {

    let authToken: String
    let authTokenSecret: String
    let userID: String

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        if let authToken: String = aDecoder.decodeObject(forKey: "authToken") as? String {
            self.authToken = authToken
        } else {
            return nil
        }

        if let authTokenSecret: String = aDecoder.decodeObject(forKey: "authTokenSecret") as? String {
            self.authTokenSecret = authTokenSecret
        } else {
            return nil
        }

        if let userID: String = aDecoder.decodeObject(forKey: "userID") as? String {
            self.userID = userID
        } else {
            return nil
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.authToken, forKey: "authToken")
        aCoder.encode(self.authTokenSecret, forKey: "authTokenSecret")
        aCoder.encode(self.userID, forKey: "userID")
    }

    // MARK: - Public

    init(authToken: String, authTokenSecret: String, userID: String) {
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        self.userID = userID

        super.init()
    }

}
