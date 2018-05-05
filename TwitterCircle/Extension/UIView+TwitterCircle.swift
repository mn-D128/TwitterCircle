//
//  UIView+TwitterCircle.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/22.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import ToastSwiftFramework

extension UIView {

    func makeRedToast(_ message: String) {
        var style: ToastStyle = ToastStyle()
        style.messageFont = UIFont.boldSystemFont(ofSize: style.messageFont.pointSize)
        style.messageColor = UIColor.white
        style.messageAlignment = NSTextAlignment.center
        style.backgroundColor = UIColor.flatRed()

        self.makeToast(message, style: style)
    }

}
