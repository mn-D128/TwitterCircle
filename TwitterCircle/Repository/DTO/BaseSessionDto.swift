//
//  BaseSessionDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

class BaseSessionDto {

    let authToken: String
    let authTokenSecret: String
    let userID: String

    init(authToken: String, authTokenSecret: String, userID: String) {
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        self.userID = userID
    }

}
