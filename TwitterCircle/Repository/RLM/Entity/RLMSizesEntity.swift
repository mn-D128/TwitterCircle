//
//  RLMSizesEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMSizesEntity: Object {

    @objc dynamic var large: RLMSizeEntity?
    @objc dynamic var medium: RLMSizeEntity?
    @objc dynamic var thumb: RLMSizeEntity?
    @objc dynamic var small: RLMSizeEntity?

}
