//
//  HistoryListViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/13.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift

class HistoryListViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyView: UIView!

    private let vm: HistoryListViewModel = HistoryListViewModel(historyLocalRepos: RLMHistoryLocalRepository.shared)

    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.vm.isEmptyHiddenDriver
            .drive(onNext: { [weak self] (isHidden: Bool) in
                self?.emptyView.isHidden = isHidden
            }).disposed(by: self.disposeBag)

        self.tableView.setTableEmptyFooterView()
        self.tableView.isExclusiveTouch = true
        self.tableView.register(nibClass: UserListCell.self)

        self.vm.itemsObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: UserListCell.className!)) { _, element, cell in
                guard let cell = cell as? UserListCell else {
                    return
                }

                let user: UserDto = element.user

                cell.profileImageUrl = user.profileImageUrlHttps
                cell.name = user.name
                cell.screenName = user.screenName.screenName
            }
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .modelSelected(HistoryDto.self)
            .subscribe(onNext: { [weak self] (element: HistoryDto) in
                guard let vc: CircleViewController = CircleViewController.instantiateFromStoryboard() else {
                    return
                }

                vc.user = element.user

                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: self.disposeBag)

        self.tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] (indexPath: IndexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }).disposed(by: self.disposeBag)

        self.tableView.rx
            .modelDeleted(HistoryDto.self)
            .subscribe(onNext: { [weak self] (element: HistoryDto) in
                self?.vm.deleteHistory(element)
            })
            .disposed(by: self.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.vm.viewWillAppear()
    }

}
