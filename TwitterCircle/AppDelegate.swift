//
//  AppDelegate.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/02.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import TwitterKit
import XCGLogger

let sLogger: XCGLogger? = {
    #if DEBUG
        let log: XCGLogger = XCGLogger.default
        log.setup(level: .verbose,
                  //showLogIdentifier: Bool = default,
                  //showFunctionName: Bool = default,
                  showThreadName: false,
                  showLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  //showDate: Bool = default,
                  //writeToFile: Any? = default,
                  fileLevel: .debug)
        return log
    #else
        return nil
    #endif
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Twitter初期化
        TwitterKitManager.shared
            .start(consumerKey: VendorInfo.Twitter.consumerKey,
                   consumerSecret: VendorInfo.Twitter.consumerSecret)

        let sessionLocalRepos: SessionLocalRepository = RLMSessionLocalRepository.shared
        let count: Int = sessionLocalRepos.count()

        let tabBar: TabBarController = TabBarController.instantiate()
        let nc: UINavigationController = UINavigationController(rootViewController: tabBar)
        nc.isNavigationBarHidden = true

        if count == 0 {
            guard let taVC: TwitterAuthViewController = TwitterAuthViewController.instantiateFromStoryboard() else {
                return false
            }

            nc.pushViewController(taVC, animated: false)
        }

        if let splashVC: SplashViewController = SplashViewController.instantiateFromStoryboard() {
            nc.pushViewController(splashVC, animated: false)
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = nc
        self.window?.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
