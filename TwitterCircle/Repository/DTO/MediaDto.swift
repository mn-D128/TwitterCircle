//
//  MediaDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

struct MediaDto: Equatable {

    let idStr: String
    let mediaUrlHttps: URL
    let sizes: SizesDto

    static func == (lhs: MediaDto, rhs: MediaDto) -> Bool {
        return lhs.idStr == rhs.idStr
    }

    static func != (lhs: MediaDto, rhs: MediaDto) -> Bool {
        return lhs.idStr != rhs.idStr
    }

}
