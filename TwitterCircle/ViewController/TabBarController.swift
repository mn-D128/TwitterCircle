//
//  TabBarController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import FontAwesomeKit
import RxSwift

class TabBarController: UITabBarController {

    private let vm: TabBarViewModel = TabBarViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared)
    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UIViewController

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialized()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialized()
    }

    // MARK: - Private

    private func initialized() {
        self.delegate = self

        self.vm.selectedUserIDDriver
            .drive(onNext: { [weak self] (userID: String?) in
                self?.selectedUserIDDidChange(userID)
            })
            .disposed(by: self.disposeBag)
    }

    private func selectedUserIDDidChange(_ userID: String?) {
        guard let nc: UINavigationController = self.navigationController else {
            return
        }

        if userID != nil {
            if let vc: UIViewController = nc.viewControllers.last,
                vc is TwitterAuthViewController {
                nc.fadeOutViewController(animated: true)
            }
        } else {
            guard let vc: TwitterAuthViewController = TwitterAuthViewController.instantiateFromStoryboard() else {
                return
            }

            vc.canAnimation = false
            nc.fadeInViewController(vc, animated: true)
        }
    }

}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let vcs: [UIViewController] = self.viewControllers else {
            return
        }

        for vc: UIViewController in vcs {
            guard let nc: UINavigationController = vc as? UINavigationController,
                nc.viewControllers.count == 1 else {
                continue
            }

            guard let followVC: FollowListViewController = nc.viewControllers.first as? FollowListViewController else {
                continue
            }

            guard vc != viewController else {
                continue
            }

            followVC.finishSearch()
        }
    }

}

extension TabBarController {

    // MARK: - Public

    static func instantiate() -> TabBarController {
        var vcs: [UIViewController] = []

        if let vc: MyCircleViewController = MyCircleViewController.instantiateFromStoryboard() {
            vc.title = "MYCIRCLE_TITLE".localized

            let nc: UINavigationController = self.instantiateNavigationController(vc,
                                                                                  icon: FAKFontAwesome.userCircleIcon(withSize: 30.0),
                                                                                  tag: vcs.count)
            vcs.append(nc)
        }

        if let vc: FollowListViewController = FollowListViewController.instantiateFromStoryboard() {
            vc.title = "FOLLOWLIST_TITLE".localized

            let nc: UINavigationController = self.instantiateNavigationController(vc,
                                                                                  icon: FAKFontAwesome.listIcon(withSize: 30.0),
                                                                                  tag: vcs.count)
            vcs.append(nc)
        }

        if let vc: HistoryListViewController = HistoryListViewController.instantiateFromStoryboard() {
            vc.title = "HISTORYLIST_TITLE".localized

            let nc: UINavigationController = self.instantiateNavigationController(vc,
                                                                                  icon: FAKFontAwesome.historyIcon(withSize: 30.0),
                                                                                  tag: vcs.count)
            vcs.append(nc)
        }

        if let vc: SettingViewController = SettingViewController.instantiateFromStoryboard() {
            vc.title = "SETTING_TITLE".localized

            let nc: UINavigationController = self.instantiateNavigationController(vc,
                                                                                  icon: FAKFontAwesome.cogIcon(withSize: 30.0),
                                                                                  tag: vcs.count)
            vcs.append(nc)
        }

        let result: TabBarController = TabBarController()
        result.viewControllers = vcs
        return result
    }

    // MARK: - Private

    static private func instantiateNavigationController(_ vc: UIViewController, icon: FAKIcon, tag: Int) -> UINavigationController {
        let iconImage: UIImage = icon.image(with: CGSize(width: 30.0, height: 30.0))

        let nc: UINavigationController = UINavigationController(rootViewController: vc)
        nc.tabBarItem = UITabBarItem(title: vc.title,
                                     image: iconImage,
                                     tag: tag)

        return nc
    }

}
