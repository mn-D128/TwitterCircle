//
//  TwitterAuthViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/02.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD
import SwiftyGif

class TwitterAuthViewController: UIViewController {

    @IBOutlet private weak var logoIV: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var loginBtn: UIButton!

    @IBOutlet private weak var logoIVCenterY: NSLayoutConstraint!
    @IBOutlet private weak var loginBtnHeight: NSLayoutConstraint!
    @IBOutlet private weak var loginBtnWidth: NSLayoutConstraint!

    private let vm: TwitterAuthViewModel = TwitterAuthViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                                                                userRepos: TKUserRepository.shared,
                                                                userLocalRepos: RLMUserLocalRepository.shared)

    private let disposeBag: DisposeBag = DisposeBag()

    private let toLogoIVCenterY: CGFloat = -80.0

    private var gif: UIImage = {
        let gifName: String = String(format: "splash_icon@%.0fx.gif", UIScreen.main.scale)
        return UIImage(gifName: gifName)
    }()

    var canAnimation: Bool = true

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel(self.vm, disposeBag: self.disposeBag)
        self.loginBtnDidLoad()

        self.logoIV.setGifImage(self.gif, loopCount: 0)
        let index: Int = self.gif.framesCount() - 1
        let image: UIImage = self.logoIV.frameAtIndex(index: index)
        SwiftyGifManager.defaultManager.deleteImageView(self.logoIV)
        self.logoIV.image = image

        if self.canAnimation {
            self.contentView.isHidden = true
        } else {
            self.contentView.isHidden = false
            self.logoIVCenterY.constant = self.toLogoIVCenterY
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.contentView.isHidden {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.startAnimation()
        }
    }

    // MARK: - Private

    private func loginBtnDidLoad() {
        if let titleLbl: UILabel = self.loginBtn.titleLabel {
            if let text: String = titleLbl.text {
                let size: CGSize = (text as NSString).size(withAttributes: [NSAttributedStringKey.font: titleLbl.font])
                self.loginBtnWidth.constant = size.width.round + 20.0 * 2.0
            }

            let lineHeight: CGFloat = titleLbl.font.lineHeight
            self.loginBtnHeight.constant = lineHeight + 10.0 * 2.0
        }

        let normalColor: UIColor = UIColor(base255Red: 85, green: 172, blue: 238)
        self.loginBtn.setBackgroundColor(normalColor, for: UIControlState.normal)

        let highlightedColor: UIColor = normalColor.withAlphaComponent(0.3)
        self.loginBtn.setBackgroundColor(highlightedColor, for: UIControlState.highlighted)

        self.loginBtn.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.vm.loginAcount()
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: -

    private func startAnimation() {
        let animations: () -> Void = { [weak self] in
            self?.logoIV.superview?.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { [weak self] (finish: Bool) in
            self?.nextAnimation()
        }

        self.logoIVCenterY.constant = self.toLogoIVCenterY

        UIView.animate(withDuration: 1.0,
                       animations: animations,
                       completion: completion)
    }

    private func nextAnimation() {
        self.contentView.isHidden = false
        self.contentView.alpha = 0.0

        let animations: () -> Void = { [weak self] in
            self?.contentView.alpha = 1.0
        }

        UIView.animate(withDuration: 1.0,
                       animations: animations)
    }

}
