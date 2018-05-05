//
//  RetweetedStatusDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension RetweetedStatusDto: ImmutableMappable {

    init(map: Map) throws {
        self.idStr = try map.value("id_str")
        self.user = try map.value("user")
    }

    func mapping(map: Map) {
        self.idStr >>> map["id_str"]
        self.user >>> map["user"]
    }

}
