//
//  RLMTweetEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/17.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMTweetEntity: Object {

    @objc dynamic var idStr: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var retweeted: Bool = false
    @objc dynamic var retweetedStatus: RLMRetweetedStatusEntity?
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var user: RLMUserEntity?
    @objc dynamic var extendedEntities: RLMExtendedEntitiesEntity?

    override static func primaryKey() -> String? {
        return "idStr"
    }

    override static func indexedProperties() -> [String] {
        return ["createdAt"]
    }

}
