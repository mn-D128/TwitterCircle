//
//  RLMMediaEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMMediaEntity: Object {

    @objc dynamic var idStr: String = ""
    @objc dynamic private var mediaUrlHttpsStr: String = ""
    @objc dynamic var sizes: RLMSizesEntity?

    var mediaUrlHttps: URL? {
        set {
            if let newValue = newValue {
                self.mediaUrlHttpsStr = newValue.absoluteString
            } else {
                self.mediaUrlHttpsStr = ""
            }
        }

        get {
            return URL(string: self.mediaUrlHttpsStr)
        }
    }

    override static func primaryKey() -> String? {
        return "idStr"
    }

}
