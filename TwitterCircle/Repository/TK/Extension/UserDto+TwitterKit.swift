//
//  UserDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension UserDto: ImmutableMappable {

    init(map: Map) throws {
        self.name = try map.value("name")
        self.createdAt = try map.value("created_at")
        self.idStr = try map.value("id_str")
        self.profileImageUrlHttps = try map.value("profile_image_url_https", using: URLTransform())
        self.screenName = try map.value("screen_name")
    }

    mutating func mapping(map: Map) {
        self.name >>> map["name"]
        self.createdAt >>> map["created_at"]
        self.idStr >>> map["id_str"]
        self.profileImageUrlHttps >>> (map["profile_image_url_https"], URLTransform())
        self.screenName >>> map["screen_name"]
    }

}
