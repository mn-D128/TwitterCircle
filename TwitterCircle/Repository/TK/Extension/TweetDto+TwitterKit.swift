//
//  TweetDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension TweetDto: ImmutableMappable {

    init(map: Map) throws {
        self.idStr = try map.value("id_str")
        self.text = try map.value("text")
        self.retweeted = try map.value("retweeted")
        self.createdAt = try map.value("created_at", using: TKDateTransform())
        self.user = try map.value("user")
        self.retweetedStatus = try? map.value("retweeted_status")
        self.extendedEntities = try? map.value("extended_entities")
    }

    func mapping(map: Map) {
        self.idStr >>> map["id_str"]
        self.text >>> map["text"]
        self.retweeted >>> map["retweeted"]
        self.createdAt >>> map["created_at"]
        self.user >>> map["user"]
        self.retweetedStatus >>> map["retweeted_status"]
        self.extendedEntities >>> map["extended_entities"]
    }

}
