//
//  HistoryListViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/13.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class HistoryListViewModel {

    private let historyLocalRepos: HistoryLocalRepository

    private let isEmptyHidden: Variable<Bool> = Variable<Bool>(false)
    lazy var isEmptyHiddenDriver: SharedSequence = {
        return self.isEmptyHidden.asDriver()
    }()

    private let items: Variable<[HistoryDto]> = Variable<[HistoryDto]>([])
    lazy var itemsObservable: Observable<[HistoryDto]> = {
        return self.items.asObservable()
    }()

    private var token: Any?

    private var selectedUserID: String? {
        didSet {
            self.historyLocalRepos.invalidateObserve(self.token)
            self.token = nil

            guard let userID: String = self.selectedUserID else {
                return
            }

            let change: () -> Void = { [weak self] in
                guard let weakSelf = self,
                    let userID: String = weakSelf.selectedUserID else {
                    return
                }

                weakSelf.items.value = weakSelf.historyLocalRepos.findAll(userID)
                weakSelf.isEmptyHidden.value = !weakSelf.items.value.isEmpty
            }
            self.token = self.historyLocalRepos.observe(userID, change: change)

            self.items.value = self.historyLocalRepos.findAll(userID)
            self.isEmptyHidden.value = !self.items.value.isEmpty
        }
    }

    init(historyLocalRepos: HistoryLocalRepository) {
        self.historyLocalRepos = historyLocalRepos

        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(userDefaultsDidChange(_:)),
                         name: UserDefaults.didChangeNotification,
                         object: nil)
    }

    deinit {
        NotificationCenter.default
            .removeObserver(self)

        self.historyLocalRepos.invalidateObserve(self.token)
    }

    // MARK: - Public

    func viewWillAppear() {
        self.updateSelectedUserIDIfNeeded()
    }

    func deleteHistory(_ history: HistoryDto) {
        self.historyLocalRepos.delete(history)
    }

    // MARK: - Private

    private func updateSelectedUserIDIfNeeded() {
        let selectedUserID: String? = Defaults[DefaultsKeys.selectedUserID]
        if self.selectedUserID != selectedUserID {
            self.selectedUserID = selectedUserID
        }
    }

    // MARK: - NotificationCenter

    @objc private func userDefaultsDidChange(_ notification: Notification) {
        self.updateSelectedUserIDIfNeeded()
    }

}
