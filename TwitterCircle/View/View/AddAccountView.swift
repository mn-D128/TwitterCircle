//
//  AddAccountView.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import FontAwesomeKit

class AddAccountView: UIControl {

    @IBOutlet private weak var iconIV: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!

    @IBOutlet private weak var separatorHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.separatorHeight.constant = 1.0 / UIScreen.main.scale

        let icon: FAKIcon = FAKFontAwesome.userPlusIcon(withSize: 26.0)
        icon.setAttributes([
            NSAttributedStringKey.foregroundColor: self.titleLbl.textColor
        ])

        let iconImage: UIImage = icon.image(with: self.iconIV.frame.size)
        self.iconIV.image = iconImage

        if let highlightedColor: UIColor = self.titleLbl.highlightedTextColor {
            icon.setAttributes([
                NSAttributedStringKey.foregroundColor: highlightedColor
            ])
            self.iconIV.highlightedImage = icon.image(with: self.iconIV.frame.size)
        }
    }

    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            self.iconIV.isHighlighted = newValue
            self.titleLbl.isHighlighted = newValue
        }

        get {
            return super.isHighlighted
        }
    }

}
