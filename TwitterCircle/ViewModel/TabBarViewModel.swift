//
//  TabBarViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class TabBarViewModel {

    private let sessionLocalRepos: SessionLocalRepository

    private let selectedUserID: Variable<String?>
    lazy var selectedUserIDDriver: SharedSequence = {
        return self.selectedUserID.asDriver()
    }()

    init(sessionLocalRepos: SessionLocalRepository) {
        self.sessionLocalRepos = sessionLocalRepos

        self.selectedUserID = Variable<String?>(Defaults[DefaultsKeys.selectedUserID])

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(userDefaultsDidChange(_:)),
                         name: UserDefaults.didChangeNotification,
                         object: nil)
    }

    deinit {
        NotificationCenter.default
            .removeObserver(self)
    }

    // MARK: - Private

    private func updateSelectedUserIDIfNeeded() {
        let selectedUserID: String? = Defaults[DefaultsKeys.selectedUserID]
        if self.selectedUserID.value != selectedUserID {
            self.selectedUserID.value = selectedUserID
        }
    }

    // MARK: - NotificationCenter

    @objc private func userDefaultsDidChange(_ notification: Notification) {
        self.updateSelectedUserIDIfNeeded()
    }

}
