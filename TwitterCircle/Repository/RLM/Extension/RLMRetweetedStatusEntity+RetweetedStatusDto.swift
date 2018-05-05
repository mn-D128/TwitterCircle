//
//  RLMRetweetedStatusEntity+RetweetedStatusDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMRetweetedStatusEntity {

    convenience init(retweetedStatusDto dto: RetweetedStatusDto) {
        self.init()

        self.idStr = dto.idStr
        self.user = RLMUserEntity(userDto: dto.user)
    }

    var retweetedStatusDto: RetweetedStatusDto? {
        guard let user: UserDto = self.user?.userDto else {
            return nil
        }

        return RetweetedStatusDto(idStr: self.idStr,
                                  user: user)
    }

}
