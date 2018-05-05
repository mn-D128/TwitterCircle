//
//  RLMSessionEntity+SessionDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMSessionEntity {

    var sessionDto: SessionDto? {
        guard let user: UserDto = self.user?.userDto else {
            return nil
        }

        return SessionDto(authToken: self.authToken,
                          authTokenSecret: self.authTokenSecret,
                          user: user)
    }

    convenience init(sessionDto session: SessionDto) {
        self.init()

        self.authToken = session.authToken
        self.authTokenSecret = session.authTokenSecret
        self.userID = session.userID
        self.user = RLMUserEntity(userDto: session.user)
    }

}
