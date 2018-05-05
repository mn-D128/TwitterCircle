//
//  RLMFriendResponseEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/11.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMFriendResponseEntity: Object {

    @objc dynamic var nextCursor: Int = 0
    @objc dynamic var userID: String = ""

    let users: List<RLMUserEntity> = List<RLMUserEntity>()

    override static func primaryKey() -> String? {
        return "userID"
    }

}
