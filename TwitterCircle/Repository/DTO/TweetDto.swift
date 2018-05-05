//
//  TweetDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

struct TweetDto: Equatable {

    let idStr: String
    let text: String
    let createdAt: Date
    let user: UserDto

    let retweeted: Bool
    let retweetedStatus: RetweetedStatusDto?

    let extendedEntities: ExtendedEntitiesDto?

    static func == (lhs: TweetDto, rhs: TweetDto) -> Bool {
        return lhs.idStr == rhs.idStr
    }

    static func != (lhs: TweetDto, rhs: TweetDto) -> Bool {
        return lhs.idStr != rhs.idStr
    }

}
