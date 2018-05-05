//
//  RLMSizesEntity+SizesDtop.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMSizesEntity {

    convenience init(sizesDto dto: SizesDto) {
        self.init()

        self.large = RLMSizeEntity(sizeDto: dto.large)
        self.medium = RLMSizeEntity(sizeDto: dto.medium)
        self.thumb = RLMSizeEntity(sizeDto: dto.thumb)
        self.small = RLMSizeEntity(sizeDto: dto.small)
    }

    var sizesDto: SizesDto? {
        guard let large: SizeDto = self.large?.sizeDto,
            let medium: SizeDto = self.medium?.sizeDto,
            let thumb: SizeDto = self.thumb?.sizeDto,
            let small: SizeDto = self.small?.sizeDto else {
            return nil
        }

        return SizesDto(large: large,
                        medium: medium,
                        thumb: thumb,
                        small: small)
    }

}
