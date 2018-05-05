//
//  SizeDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension SizeDto: ImmutableMappable {

    init(map: Map) throws {
        self.w = try map.value("w")
        self.h = try map.value("h")
        self.resize = try map.value("resize", using: EnumTransform<Resize>())
    }

    func mapping(map: Map) {
        self.w >>> map["w"]
        self.h >>> map["h"]
        self.resize >>> (map["resize"], EnumTransform<Resize>())
    }

}
