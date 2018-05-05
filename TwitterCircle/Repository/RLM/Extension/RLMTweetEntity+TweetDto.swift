//
//  RLMTweetEntity+TweetDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/17.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMTweetEntity {

    convenience init(tweetDto: TweetDto) {
        self.init()

        self.idStr = tweetDto.idStr
        self.text = tweetDto.text
        self.retweeted = tweetDto.retweeted

        if let dto: RetweetedStatusDto = tweetDto.retweetedStatus {
            self.retweetedStatus = RLMRetweetedStatusEntity(retweetedStatusDto: dto)
        }

        self.createdAt = tweetDto.createdAt
        self.user = RLMUserEntity(userDto: tweetDto.user)

        if let dto: ExtendedEntitiesDto = tweetDto.extendedEntities {
            self.extendedEntities = RLMExtendedEntitiesEntity(extendedEntitiesDto: dto)
        }
    }

    var tweetDto: TweetDto? {
        guard let user: UserDto = self.user?.userDto else {
            return nil
        }

        let retweetedStatus: RetweetedStatusDto? = self.retweetedStatus?.retweetedStatusDto
        let extendedEntities: ExtendedEntitiesDto? = self.extendedEntities?.extendedEntitiesDto

        return TweetDto(idStr: self.idStr,
                        text: self.text,
                        createdAt: self.createdAt,
                        user: user,
                        retweeted: self.retweeted,
                        retweetedStatus: retweetedStatus,
                        extendedEntities: extendedEntities)
    }

}
