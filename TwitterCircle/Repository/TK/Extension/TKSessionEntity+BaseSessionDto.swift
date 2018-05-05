//
//  TKSessionEntity+BaseSessionDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension TKSessionEntity {

    convenience init(baseSessionDto session: BaseSessionDto) {
        self.init(authToken: session.authToken,
                  authTokenSecret: session.authTokenSecret,
                  userID: session.userID)
    }

}
