//
//  SplashViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/17.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import SwiftyGif

class SplashViewController: UIViewController, SwiftyGifDelegate {

    @IBOutlet private var imageView: UIImageView!

    private var gif: UIImage = {
        let gifName: String = String(format: "splash_icon@%.0fx.gif", UIScreen.main.scale)
        return UIImage(gifName: gifName)
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.setGifImage(self.gif, loopCount: 1)
        self.imageView.stopAnimatingGif()
        self.imageView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.imageView.startAnimatingGif()
    }

    // MARK: - Private

    private func finishGifAnimation() {
        guard let nc: UINavigationController = self.navigationController else {
            return
        }

        for vc: UIViewController in nc.viewControllers where vc is TwitterAuthViewController {
            nc.popViewController(animated: false)
            return
        }

        nc.fadeOutViewController(animated: true)
    }

    // MARK: - SwiftyGifDelegate

    func gifDidStop(sender: UIImageView) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.finishGifAnimation()
        })
    }

}
