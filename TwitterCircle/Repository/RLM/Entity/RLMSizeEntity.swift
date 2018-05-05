//
//  RLMSizeEntity.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/24.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMSizeEntity: Object {

    @objc dynamic var w: Int = 0
    @objc dynamic var h: Int = 0
    @objc dynamic private var resizeStr: String = Resize.fit.rawValue

    var resize: Resize {
        set {
            self.resizeStr = newValue.rawValue
        }

        get {
            return Resize(rawValue: self.resizeStr)!
        }
    }

}
