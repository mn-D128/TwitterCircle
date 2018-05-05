//
//  RLMSessionEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMSessionEntity: Object {

    @objc dynamic var userID: String = ""
    @objc dynamic var authToken: String = ""
    @objc dynamic var authTokenSecret: String = ""

    @objc dynamic var user: RLMUserEntity?

    override static func primaryKey() -> String? {
        return "userID"
    }

}
