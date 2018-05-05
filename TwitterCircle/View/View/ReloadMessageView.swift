//
//  ReloadMessageView.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/18.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import FontAwesomeKit

class ReloadMessageView: UIControl {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let icon: FAKFontAwesome = FAKFontAwesome.repeatIcon(withSize: 20.0)
        icon.setAttributes([
            NSAttributedStringKey.foregroundColor: self.messageLbl.textColor
        ])
        self.imageView.image = icon.image(with: self.imageView.frame.size)

        if let highlightedColor: UIColor = self.messageLbl.highlightedTextColor {
            icon.setAttributes([
                NSAttributedStringKey.foregroundColor: highlightedColor
            ])
            self.imageView.highlightedImage = icon.image(with: self.imageView.frame.size)
        }
    }

    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            self.imageView.isHighlighted = newValue
            self.messageLbl.isHighlighted = newValue
        }

        get {
            return super.isHighlighted
        }
    }

}
