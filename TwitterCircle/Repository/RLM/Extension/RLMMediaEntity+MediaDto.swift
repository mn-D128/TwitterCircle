//
//  RLMMediaEntity+MediaDto.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMMediaEntity {

    convenience init(mediaDto dto: MediaDto) {
        self.init()

        self.idStr = dto.idStr
        self.mediaUrlHttps = dto.mediaUrlHttps
        self.sizes = RLMSizesEntity(sizesDto: dto.sizes)
    }

    var mediaDto: MediaDto? {
        guard let mediaUrlHttps: URL = self.mediaUrlHttps,
            let sizes: SizesDto = self.sizes?.sizesDto else {
            return nil
        }

        return MediaDto(idStr: self.idStr,
                        mediaUrlHttps: mediaUrlHttps,
                        sizes: sizes)
    }

}
