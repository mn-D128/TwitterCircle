//
//  SessionDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/05.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

class SessionDto: BaseSessionDto {

    let user: UserDto

    init(authToken: String, authTokenSecret: String, user: UserDto) {
        self.user = user

        super.init(authToken: authToken, authTokenSecret: authTokenSecret, userID: user.idStr)
    }

    init(baseSession: BaseSessionDto, user: UserDto) {
        self.user = user

        super.init(authToken: baseSession.authToken,
                   authTokenSecret: baseSession.authTokenSecret,
                   userID: user.idStr)
    }

}
