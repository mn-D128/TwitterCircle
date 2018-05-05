//
//  CircleViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import RxSwift

class CircleViewController: BaseCircleViewController {

    var user: UserDto? {
        didSet {
            self.vm.setUser(user)
        }
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private lazy var vm: CircleViewModel = {
        return CircleViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                               userTimelineRepos: TKUserTimelineRepository.shared,
                               tweetLocalRepos: RLMTweetLocalRepository.shared)
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.vm.closeDriver
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: false)
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: - BaseCircleViewController

    override func viewModel() -> BaseCircleViewModel {
        return self.vm
    }

}
