//
//  RLMHistoryEntity+HistoryDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMHistoryEntity {

    var historyDto: HistoryDto? {
        guard let user: UserDto = self.user?.userDto else {
            return nil
        }

        return HistoryDto(id: self.id,
                          userID: self.userID,
                          user: user,
                          updatedAt: self.updatedAt)
    }

    convenience init(historyDto: HistoryDto) {
        self.init()

        self.id = historyDto.id
        self.userID = historyDto.userID
        self.user = RLMUserEntity(userDto: historyDto.user)
        self.updatedAt = historyDto.updatedAt
    }

}
