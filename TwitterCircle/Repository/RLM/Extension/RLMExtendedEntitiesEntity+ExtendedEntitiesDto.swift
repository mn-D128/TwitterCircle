//
//  RLMExtendedEntitiesEntity+ExtendedEntitiesDto.swift
//  TwitterCircle
//
//  Created by mn(D128). on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

extension RLMExtendedEntitiesEntity {

    convenience init(extendedEntitiesDto dto: ExtendedEntitiesDto) {
        self.init()

        for media: MediaDto in dto.medias {
            self.medias.append(RLMMediaEntity(mediaDto: media))
        }
    }

    var extendedEntitiesDto: ExtendedEntitiesDto? {
        var medias: [MediaDto] = [MediaDto]()

        for mediaEntity: RLMMediaEntity in self.medias {
            if let media: MediaDto = mediaEntity.mediaDto {
                medias.append(media)
            }
        }

        return ExtendedEntitiesDto(medias: medias)
    }

}
