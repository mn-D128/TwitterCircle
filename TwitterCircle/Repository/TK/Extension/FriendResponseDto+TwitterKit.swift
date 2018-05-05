//
//  FriendResponseDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension FriendResponseDto: ImmutableMappable {

    init(map: Map) throws {
        self.nextCursor = try map.value("next_cursor")

        self.users = (try? map.value("users")) ?? []
    }

    func mapping(map: Map) {
        self.nextCursor >>> map["next_cursor"]

        self.users >>> map["users"]
    }

}
