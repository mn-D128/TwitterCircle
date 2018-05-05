//
//  UserListCell.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/07.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import Nuke

class UserListCell: UITableViewCell {

    @IBOutlet private weak var profileIV: UIImageView!
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var screenNameLbl: UILabel!

    private var tokenSource: CancellationTokenSource?

    var name: String? {
        set {
            self.nameLbl.text = newValue
        }

        get {
            return self.nameLbl.text
        }
    }

    var screenName: String? {
        set {
            self.screenNameLbl.text = newValue
        }

        get {
            return self.screenNameLbl.text
        }
    }

    var profileImageUrl: URL? {
        didSet {
            self.tokenSource?.cancel()
            self.tokenSource = nil

            guard let url: URL = self.profileImageUrl else {
                self.profileIV.image = nil
                return
            }

            let completion: (Nuke.Result<Image>) -> Void = { [weak self] (result: Nuke.Result<Image>) in
                guard let weakSelf: UserListCell = self else {
                    return
                }

                weakSelf.tokenSource = nil

                switch result {
                case .success(let image):
                    weakSelf.profileIV.image = image

                case .failure(let error):
                    sLogger?.error(error)
                }
            }

            let tokenSource: CancellationTokenSource = CancellationTokenSource()
            self.tokenSource = tokenSource

            Nuke.Manager.shared.loadImage(with: url,
                                          token: tokenSource.token,
                                          completion: completion)
        }
    }

    // MARK: - NSObject

    deinit {
        self.tokenSource?.cancel()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.profileIV.layer.cornerRadius = self.profileIV.frame.width / 2.0
    }

    // MARK: - UITableViewCell

    override func prepareForReuse() {
        super.prepareForReuse()

        self.profileImageUrl = nil
    }

}
