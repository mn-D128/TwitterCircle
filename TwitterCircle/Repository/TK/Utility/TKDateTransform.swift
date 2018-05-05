//
//  TKDateTransform.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import ObjectMapper

class TKDateTransform: DateFormatterTransform {

    private static let reusableDateFormatter = DateFormatter(withFormat: "EEE MMM d HH:mm:ss Z y",
                                                             locale: "en_US_POSIX")

    init() {
        super.init(dateFormatter: type(of: self).reusableDateFormatter)
    }

}
