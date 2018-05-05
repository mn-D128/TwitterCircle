//
//  RLMHistoryEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/13.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMHistoryEntity: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var userID: String = ""
    @objc dynamic var user: RLMUserEntity?
    @objc dynamic var updatedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }

}
