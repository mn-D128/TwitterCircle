//
//  AccountListViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift
import MBProgressHUD

class AccountListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private let vm: AccountListViewModel = AccountListViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                                                                friendLocalRepos: RLMFriendLocalRepository.shared,
                                                                historyLocalRepos: RLMHistoryLocalRepository.shared,
                                                                userRepos: TKUserRepository.shared,
                                                                userLocalRepos: RLMUserLocalRepository.shared)

    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bindViewModel(self.vm, disposeBag: self.disposeBag)

        self.setupAddAccount()

        self.tableView.setTableEmptyFooterView()
        self.tableView.register(nibClass: UserListCell.self)

        self.vm.itemsObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: UserListCell.className!)) { _, element, cell in
                guard let cell = cell as? UserListCell else {
                    return
                }

                let user: UserDto = element.user

                cell.accessoryType = element.isSelected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
                cell.profileImageUrl = user.profileImageUrlHttps
                cell.name = user.name
                cell.screenName = user.screenName.screenName
            }
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .modelSelected(SessionDto.self)
            .subscribe(onNext: { [weak self] (session: SessionDto) in
                self?.vm.selectAccount(session)
            })
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] (indexPath: IndexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .modelDeleted(SessionDto.self)
            .subscribe(onNext: { [weak self] (session: SessionDto) in
                self?.vm.deleteAccount(session)
            })
            .disposed(by: self.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "ACCOUNTLIST_TITLE".localized

        self.vm.viewWillAppear()
    }

    // MARK: - Private

    private func setupAddAccount() {
        guard let addAccountView: AddAccountView = AddAccountView.instantiate() else {
            return
        }

        var rect: CGRect = addAccountView.frame
        rect.size.width = self.tableView.frame.width
        rect.size.height = 43.0
        addAccountView.frame = rect
        addAccountView.isExclusiveTouch = true
        addAccountView.autoresizingMask = [UIViewAutoresizing.flexibleWidth]

        addAccountView.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.vm.addAcount()
            })
            .disposed(by: self.disposeBag)

        self.tableView.tableHeaderView = addAccountView
    }

}
