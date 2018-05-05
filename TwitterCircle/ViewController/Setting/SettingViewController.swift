//
//  SettingViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift

protocol IndexRow {

    func shouldHighlight() -> Bool

}

class SettingViewController: UITableViewController {

    @IBOutlet private weak var versionLbl: UILabel!

    private let disposeBag: DisposeBag = DisposeBag()

    enum Section: Int {
        case account
        case version

        static func row(_ indexPath: IndexPath) -> IndexRow? {
            return Section(rawValue: indexPath.section)?.row(indexPath.row)
        }

        func row(_ row: Int) -> IndexRow? {
            switch self {
            case .account:
                return Account(rawValue: row)

            case .version:
                return Version(rawValue: row)
            }
        }

    }

    enum Account: Int, IndexRow {
        case account

        func shouldHighlight() -> Bool {
            switch self {
            case .account: return true
            }
        }

    }

    enum Version: Int, IndexRow {
        case version

        func shouldHighlight() -> Bool {
            switch self {
            case .version: return false
            }
        }

    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.versionLbl.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

        self.tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] (indexPath: IndexPath) in
                self?.itemSelected(indexPath)
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: - Private

    private func itemSelected(_ indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        guard let indexRow: IndexRow = Section.row(indexPath) else {
            return
        }

        if let account: Account = indexRow as? Account {
            switch account {
            case .account:
                if let vc: AccountListViewController = AccountListViewController.instantiateFromStoryboard() {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return Section.row(indexPath)?.shouldHighlight() ?? true
    }

}
