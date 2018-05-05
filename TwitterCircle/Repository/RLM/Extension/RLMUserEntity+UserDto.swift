//
//  RLMUserEntity+UserDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMUserEntity {

    convenience init(userDto user: UserDto) {
        self.init()

        self.createdAt = user.createdAt
        self.idStr = user.idStr
        self.name = user.name
        self.profileImageUrlHttps = user.profileImageUrlHttps
        self.screenName = user.screenName
    }

    var userDto: UserDto {
        return UserDto(name: self.name,
                       createdAt: self.createdAt,
                       idStr: self.idStr,
                       profileImageUrlHttps: self.profileImageUrlHttps!,
                       screenName: self.screenName)
    }

}
