//
//  RLMUserEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/11.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMUserEntity: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var idStr: String = ""

    @objc dynamic private var profileImageUrlHttpsStr: String = ""
    var profileImageUrlHttps: URL? {
        set {
            if let newValue = newValue {
                self.profileImageUrlHttpsStr = newValue.absoluteString
            } else {
                self.profileImageUrlHttpsStr = ""
            }
        }

        get {
            return URL(string: self.profileImageUrlHttpsStr)
        }
    }

    @objc dynamic var screenName: String = ""

    override static func primaryKey() -> String? {
        return "idStr"
    }

}
