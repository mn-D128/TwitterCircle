//
//  SizesDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension SizesDto: ImmutableMappable {

    init(map: Map) throws {
        self.large = try map.value("large")
        self.medium = try map.value("medium")
        self.thumb = try map.value("thumb")
        self.small = try map.value("small")
    }

    func mapping(map: Map) {
        self.large >>> map["large"]
        self.medium >>> map["medium"]
        self.thumb >>> map["thumb"]
        self.small >>> map["small"]
    }

}
