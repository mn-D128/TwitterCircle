//
//  FollowListViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/05.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ToastSwiftFramework
import Chameleon

class FollowListViewController: UIViewController {

    @IBOutlet private weak var tableView: NextLoaderTableView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var emptyView: ReloadMessageView!
    @IBOutlet private weak var noResultSearchView: UIView!

    @IBOutlet private weak var contentViewBottom: NSLayoutConstraint!

    private let vm: FollowListViewModel = FollowListViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                                                              friendRepos: TKFriendRepository.shared,
                                                              friendLocalRepos: RLMFriendLocalRepository.shared,
                                                              historyLocalRepos: RLMHistoryLocalRepository.shared)

    private lazy var refreshBarBtnItem: UIBarButtonItem = {
        let item: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh,
                                                    target: self,
                                                    action: #selector(refreshBarBtnItemDidTap(_:)))
        return item
    }()

    private lazy var searchController: UISearchController = {
        let sc: UISearchController = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false

        sc.rx
            .willPresent
            .subscribe(onNext: { [weak self] in
                self?.vm.searchWillPresent()
            })
            .disposed(by: self.disposeBag)

        sc.rx
            .willDismiss.subscribe(onNext: { [weak self] in
                self?.vm.searchWillDismiss()
            })
            .disposed(by: self.disposeBag)

        return sc
    }()

    private let disposeBag: DisposeBag = DisposeBag()

    // MARK: - NSObject

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.toastErrorMessageBindViewModel(self.vm, disposeBag: disposeBag)

        self.tableViewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }

        self.emptyView.isExclusiveTouch = true

        self.vm.isProgressHiddenDriver
            .drive(onNext: { [weak self] (isHidden: Bool) in
                self?.progressView.isHidden = isHidden
            })
            .disposed(by: self.disposeBag)

        self.vm.isEmptyHiddenDriver
            .drive(onNext: { [weak self] (isHidden: Bool) in
                self?.emptyView.isHidden = isHidden
            })
            .disposed(by: self.disposeBag)

        self.vm.isNoResultSearchHiddenDriver
            .drive(onNext: { [weak self] (isHidden: Bool) in
                self?.noResultSearchView.isHidden = isHidden
            })
            .disposed(by: self.disposeBag)

        self.emptyView.rx
            .controlEvent(UIControlEvents.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.vm.refresh()
            })
            .disposed(by: self.disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.setRightBarButton(refreshBarBtnItem, animated: animated)

        let nc: NotificationCenter = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(keyboardWillShow(_:)),
                       name: .UIKeyboardWillShow,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(keyboardWillHide(_:)),
                       name: .UIKeyboardWillHide,
                       object: nil)

        self.vm.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let nc: NotificationCenter = NotificationCenter.default
        nc.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        nc.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

        self.vm.viewWillDisappear()
    }

    // MARK: - Private

    private func tableViewDidLoad() {
        self.tableView.register(nibClass: UserListCell.self)
        self.tableView.didNextLoad = { [weak self] in
            self?.vm.loadNext()
        }

        self.vm.hasNextDriver
            .drive(onNext: { [weak self] (hasNext: Bool) in
                self?.tableView.hasNext = hasNext
            })
            .disposed(by: self.disposeBag)

        self.vm.itemsObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: UserListCell.className!)) { _, element, cell in
                guard let cell = cell as? UserListCell else {
                    return
                }

                cell.profileImageUrl = element.profileImageUrlHttps
                cell.name = element.name
                cell.screenName = element.screenName.screenName
            }
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .modelSelected(UserDto.self)
            .subscribe(onNext: { [weak self] (element: UserDto) in
                self?.selectUser(element)
            })
            .disposed(by: self.disposeBag)

        self.tableView.rx
            .itemSelected
            .subscribe(onNext: { [weak self] (indexPath: IndexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: -

    private func selectUser(_ user: UserDto) {
        guard let nc: UINavigationController = self.navigationController,
            let vc: CircleViewController = CircleViewController.instantiateFromStoryboard() else {
            return
        }

        self.searchController.isActive = false

        self.vm.selectUser(user)

        vc.user = user

        nc.pushViewController(vc, animated: true)
    }

    // MARK: - Public

    func finishSearch() {
        self.searchController.isActive = false
    }

    // MARK: - Action

    @objc private func refreshBarBtnItemDidTap(_ sender: Any) {
        self.vm.refresh()
    }

    // MARK: - Notification

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let curve: UIViewAnimationOptions = notification.keyboardAnimationCurve,
            let duration: TimeInterval = notification.keyboardAnimationDuration,
            let frameBegin: CGRect = notification.keyboardFrameBegin else {
            return
        }

        let tabHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0.0
        self.contentViewBottom.constant = frameBegin.height - tabHeight

        let animations: () -> Void = { [weak self] in
            self?.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: curve,
                       animations: animations,
                       completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let curve: UIViewAnimationOptions = notification.keyboardAnimationCurve,
            let duration: TimeInterval = notification.keyboardAnimationDuration else {
                return
        }

        self.contentViewBottom.constant = 0.0

        let animations: () -> Void = { [weak self] in
            self?.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: curve,
                       animations: animations,
                       completion: nil)
    }

}

extension FollowListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let text: String? = searchController.searchBar.text
        self.vm.search(text)
    }

}
