//
//  SettingCell.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import FontAwesomeKit

class SettingCell: UITableViewCell {

    @IBOutlet private weak var iconIV: UIImageView!

    private var icon: FAKIcon?

    // MARK: - NSObject

    override func awakeFromNib() {
        super.awakeFromNib()

        if let icon: FAKIcon = self.icon {
            let iconImage: UIImage = icon.image(with: self.iconIV.frame.size)
            self.iconIV.image = iconImage
        }
    }

    // MARK: - Public

    @objc func setIconIdentifier(_ identifier: String) {
        self.icon = try? FAKFontAwesome(identifier: identifier, size: 26.0)
    }

}
