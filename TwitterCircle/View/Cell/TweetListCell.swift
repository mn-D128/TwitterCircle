//
//  TweetListCell.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/10.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import Nuke

protocol TweetListCellDelegate: NSObjectProtocol {

    func tweetListCell(_ cell: TweetListCell, didSelectedMedia media: MediaDto)

}

class TweetListCell: UserListCell {

    @IBOutlet private weak var tweetLbl: UILabel!
    @IBOutlet private weak var createdAtLbl: UILabel!
    @IBOutlet private weak var imagesView: UIView!

    @IBOutlet private weak var imagesHeight: NSLayoutConstraint!

    private var defaultImagesHeight: CGFloat = 0.0
    private var tokenSources: [CancellationTokenSource] = []

    weak var delegate: TweetListCellDelegate?

    var tweet: String? {
        set {
            self.tweetLbl.text = newValue
        }

        get {
            return self.tweetLbl.text
        }
    }

    var createdAt: String? {
        set {
            self.createdAtLbl.text = newValue
        }

        get {
            return self.createdAtLbl.text
        }
    }

    var medias: [MediaDto]? {
        didSet {
            self.updateImages()
        }
    }

    deinit {
        for tokenSource: CancellationTokenSource in self.tokenSources {
            tokenSource.cancel()
        }
        self.tokenSources.removeAll()
    }

    // MARK: - NSObject

    override func awakeFromNib() {
        super.awakeFromNib()

        self.defaultImagesHeight = self.imagesHeight.constant

        self.updateImages()
    }

    // MARK: - UITableViewCell

    override func prepareForReuse() {
        super.prepareForReuse()

        self.medias = nil
    }

    // MARK: - UIView

    override func layoutSubviews() {
        super.layoutSubviews()

        self.updateImagesLayout()
    }

    // MARK: - Public

    func rectForMedia(_ media: MediaDto) -> CGRect? {
        guard let medias: [MediaDto] = self.medias else {
            return nil
        }

        for i in 0 ..< medias.count where media == medias[i] && i < self.imagesView.subviews.count {
            let view: UIView = self.imagesView.subviews[i]

            var rect: CGRect = CGRect(origin: CGPoint.zero,
                                      size: view.frame.size)
            var superview: UIView? = view

            repeat {
                if let origin: CGPoint = superview?.frame.origin {
                    rect.origin.x += origin.x
                    rect.origin.y += origin.y
                }

                superview = superview?.superview
            } while superview != self && superview != nil

            return rect
        }

        return nil
    }

    // MARK: - Private

    private func updateImages() {
        for subview: UIView in self.imagesView.subviews.reversed() {
            subview.removeFromSuperview()
        }

        for tokenSource: CancellationTokenSource in self.tokenSources {
            tokenSource.cancel()
        }
        self.tokenSources.removeAll()

        guard let medias: [MediaDto] = self.medias, 0 < medias.count else {
            self.imagesHeight.constant = 0.0
            return
        }

        self.imagesHeight.constant = self.defaultImagesHeight

        for media: MediaDto in medias {
            let btn: ImageButton = ImageButton(type: UIButtonType.custom)
            btn.isExclusiveTouch = true
            btn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            btn.autoresizingMask = [
                UIViewAutoresizing.flexibleHeight
            ]
            btn.addTarget(self,
                          action: #selector(mediaDidTap(_:)),
                          for: UIControlEvents.touchUpInside)

            self.imagesView.addSubview(btn)

            let tokenSource: CancellationTokenSource = CancellationTokenSource()
            self.tokenSources.append(tokenSource)

            let completion: (Nuke.Result<Image>) -> Void = { (result: Nuke.Result<Image>) in
                switch result {
                case .success(let image):
                    btn.imageView?.image = image
                    btn.setImage(image, for: UIControlState.normal)

                case .failure(let error):
                    sLogger?.error(error)
                }
            }

            Nuke.Manager.shared.loadImage(with: media.mediaUrlHttps,
                                          token: tokenSource.token,
                                          completion: completion)
        }

        self.updateImagesLayout()
    }

    private func updateImagesLayout() {
        let space: CGFloat = 5.0
        var originX: CGFloat = 0.0
        let count: CGFloat = CGFloat(self.imagesView.subviews.count)
        let width: CGFloat = (self.imagesView.frame.width - (count - 1.0) * space) / count
        let height: CGFloat = self.imagesView.frame.height

        for subview: UIView in self.imagesView.subviews {
            subview.frame = CGRect(x: originX,
                                   y: 0.0,
                                   width: width,
                                   height: height)

            originX += space + width
        }
    }

    // MARK: - Action

    @objc private func mediaDidTap(_ sender: UIButton) {
        guard let medias: [MediaDto] = self.medias else {
            return
        }

        let subviews: [UIView] = self.imagesView.subviews

        for i in 0 ..< subviews.count {
            let subview: UIView = subviews[i]
            guard subview == sender else {
                continue
            }

            if medias.count <= i {
                return
            }

            self.delegate?.tweetListCell(self, didSelectedMedia: medias[i])
        }
    }

    // MARK: -

    fileprivate class ImageButton: UIButton {

        override func layoutSubviews() {
            super.layoutSubviews()

            self.imageView?.frame = self.bounds
        }

    }

}
