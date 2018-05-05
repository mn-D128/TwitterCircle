//
//  HistoryDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

struct HistoryDto {

    let id: String
    let userID: String
    let user: UserDto
    let updatedAt: Date

    init(userID: String, user: UserDto, updatedAt: Date = Date()) {
        self.id = "\(userID) \(user.idStr)"
        self.userID = userID
        self.user = user
        self.updatedAt = updatedAt
    }

    init(id: String, userID: String, user: UserDto, updatedAt: Date = Date()) {
        self.id = id
        self.userID = userID
        self.user = user
        self.updatedAt = updatedAt
    }

}
