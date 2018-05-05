//
//  ExtendedEntitiesDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension ExtendedEntitiesDto: ImmutableMappable {

    init(map: Map) throws {
        self.medias = try map.value("media")
    }

    mutating func mapping(map: Map) {
        self.medias >>> map["media"]
    }

}
