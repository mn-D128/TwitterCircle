//
//  RLMRetweetedStatusEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMRetweetedStatusEntity: Object {

    @objc dynamic var idStr: String = ""
    @objc dynamic var user: RLMUserEntity?

    override static func primaryKey() -> String? {
        return "idStr"
    }

}
