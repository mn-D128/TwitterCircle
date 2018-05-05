//
//  MediaDto+TwitterKit.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

extension MediaDto: ImmutableMappable {

    init(map: Map) throws {
        self.idStr = try map.value("id_str")
        self.mediaUrlHttps = try map.value("media_url_https", using: URLTransform())
        self.sizes = try map.value("sizes")
    }

    mutating func mapping(map: Map) {
        self.idStr >>> map["id_str"]
        self.mediaUrlHttps >>> (map["media_url_https"], URLTransform())
        self.sizes >>> map["sizes"]
    }

}
