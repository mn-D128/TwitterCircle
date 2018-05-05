//
//  DateButton.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/10.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import FontAwesomeKit

class DateButton: UIControl {

    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var iconIV: UIImageView!

    var title: String? {
        set {
            self.titleLbl.text = newValue
        }

        get {
            return self.titleLbl.text
        }
    }

    // MARK: - NSObject

    override func awakeFromNib() {
        super.awakeFromNib()

        let icon: FAKFontAwesome = FAKFontAwesome.caretDownIcon(withSize: 20.0)
        icon.setAttributes([
            NSAttributedStringKey.foregroundColor: self.titleLbl.textColor
        ])
        self.iconIV.image = icon.image(with: self.iconIV.frame.size)

        if let highlightedColor: UIColor = self.titleLbl.highlightedTextColor {
            icon.setAttributes([
                NSAttributedStringKey.foregroundColor: highlightedColor
            ])
            self.iconIV.highlightedImage = icon.image(with: self.iconIV.frame.size)
        }
    }

    // MARK: - UIControl

    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            self.titleLbl.isHighlighted = newValue
            self.iconIV.isHighlighted = newValue
        }

        get {
            return super.isHighlighted
        }
    }

}
