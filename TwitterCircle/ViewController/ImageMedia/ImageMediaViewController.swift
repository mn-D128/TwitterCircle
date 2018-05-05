//
//  ImageMediaViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/23.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift
import FontAwesomeKit
import Nuke

protocol ImageMediaViewControllerDelegate: NSObjectProtocol {

    func imageMediaViewControllerDidCancel(_ vc: ImageMediaViewController)

}

class ImageMediaViewController: UIViewController {

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var menuView: UIView!

    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            let rect: CGRect = self.initialImageRect
            self.imageView.frame = rect

            guard let media: MediaDto = self.media else {
                return
            }

            let completion: (Nuke.Result<Image>) -> Void = { [weak self] (result: Nuke.Result<Image>) in
                guard let weakSelf: ImageMediaViewController = self else {
                    return
                }

                weakSelf.tokenSource = nil

                switch result {
                case .success(let image):
                    weakSelf.imageView.image = image

                case .failure(let error):
                    sLogger?.error(error)
                }
            }

            let tokenSource: CancellationTokenSource = CancellationTokenSource()
            self.tokenSource = tokenSource

            Nuke.Manager.shared.loadImage(with: media.mediaUrlHttps,
                                          token: tokenSource.token,
                                          completion: completion)
        }
    }

    @IBOutlet private weak var closeBtn: UIButton! {
        didSet {
            let closeIcon: FAKIcon = FAKFontAwesome.closeIcon(withSize: 30.0)
            closeIcon.setAttributes([
                NSAttributedStringKey.foregroundColor: UIColor.white
            ])
            let closeImage: UIImage = closeIcon.image(with: self.closeBtn.frame.size)
            self.closeBtn.setBackgroundImage(closeImage, for: UIControlState.normal)

            self.closeBtn.isExclusiveTouch = true

            self.closeBtn.rx
                .controlEvent(UIControlEvents.touchUpInside)
                .subscribe(onNext: { [weak self] in
                    self?.startDismissAnimation()
                })
                .disposed(by: self.disposeBag)
        }
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private var media: MediaDto?
    private var initialImageRect: CGRect = CGRect.zero

    private var tokenSource: CancellationTokenSource?

    weak var delegate: ImageMediaViewControllerDelegate?

    // MARK: -

    deinit {
        self.tokenSource?.cancel()
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
   }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.startShowAnimation()
    }

    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if self.imageView.frame.size.equalTo(self.initialImageRect.size) {
            var rect: CGRect = self.imageView.frame
            let top: CGFloat = self.view.safeAreaInsets.top
            rect.origin.y = self.initialImageRect.origin.y - top
            self.imageView.frame = rect
        }

        if let superview: UIView = self.backgroundView.superview {
            let backgroundView: NSObject = self.backgroundView as NSObject
            let constraints: [NSLayoutConstraint] = superview.constraints

            for constraint: NSLayoutConstraint in constraints {
                guard let firstItem: NSObject = constraint.firstItem as? NSObject,
                    let secondItem: NSObject = constraint.secondItem as? NSObject else {
                    continue
                }

                if firstItem != backgroundView && secondItem != backgroundView {
                    continue
                }

                if constraint.firstAttribute == NSLayoutAttribute.top {
                    if constraint.constant != -self.view.safeAreaInsets.top {
                        constraint.constant = -self.view.safeAreaInsets.top
                    }
                } else if constraint.firstAttribute == NSLayoutAttribute.bottom {
                    if constraint.constant != -self.view.safeAreaInsets.bottom {
                        constraint.constant = -self.view.safeAreaInsets.bottom
                    }
                }
            }
        }
    }

    // MARK: - Public

    func setMedia(_ media: MediaDto, rect: CGRect) {
        self.media = media
        self.initialImageRect = rect
    }

    // MARK: - Private

    private func startShowAnimation() {
        let animations: () -> Void = { [weak self] in
            guard let weakSelf: ImageMediaViewController = self else {
                return
            }

            weakSelf.backgroundView.alpha = 1.0

            guard let large: SizeDto = weakSelf.media?.sizes.large,
                let size: CGSize = weakSelf.imageView.superview?.bounds.size else {
                    return
            }

            let rate: CGFloat = min(size.width / CGFloat(large.w),
                                    size.height / CGFloat(large.h))
            var rect: CGRect = CGRect(x: 0.0,
                                      y: 0.0,
                                      width: rate * CGFloat(large.w),
                                      height: rate * CGFloat(large.h))
            rect.origin.x = (size.width - rect.width) / 2.0
            rect.origin.y = (size.height - rect.height) / 2.0

            weakSelf.imageView.frame = rect
        }

        let completion: (Bool) -> Void = { [weak self] (finished: Bool) in
            self?.menuView.isHidden = false
        }

        UIView.animate(withDuration: 0.3,
                       animations: animations,
                       completion: completion)
    }

    private func startDismissAnimation() {
        let animations: () -> Void = { [weak self] in
            guard let weakSelf: ImageMediaViewController = self else {
                return
            }

            var rect: CGRect = weakSelf.initialImageRect
            if #available(iOS 11.0, *) {
                let top: CGFloat = weakSelf.view.safeAreaInsets.top
                rect.origin.y -= top
            }
            weakSelf.imageView.frame = rect

            weakSelf.backgroundView.alpha = 0.0
        }

        let completion: (Bool) -> Void = { [weak self] (finished: Bool) in
            guard let weakSelf: ImageMediaViewController = self else {
                return
            }

            weakSelf.delegate?.imageMediaViewControllerDidCancel(weakSelf)
        }

        self.menuView.isHidden = true

        UIView.animate(withDuration: 0.3,
                       animations: animations,
                       completion: completion)
    }

}
