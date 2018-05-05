//
//  SizeDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

enum Resize: String {

    case fit
    case crop

}

struct SizeDto {

    let w: Int
    let h: Int
    let resize: Resize

}
