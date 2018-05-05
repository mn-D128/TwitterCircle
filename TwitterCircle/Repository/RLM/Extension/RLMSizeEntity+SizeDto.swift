//
//  RLMSizeEntity+SizeDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMSizeEntity {

    convenience init(sizeDto dto: SizeDto) {
        self.init()

        self.w = dto.w
        self.h = dto.h
        self.resize = dto.resize
    }

    var sizeDto: SizeDto {
        return SizeDto(w: self.w, h: self.h, resize: self.resize)
    }

}
