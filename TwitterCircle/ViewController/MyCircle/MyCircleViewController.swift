//
//  MyCircleViewController.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit

class MyCircleViewController: BaseCircleViewController {

    private lazy var vm: MyCircleViewModel = {
        return MyCircleViewModel(sessionLocalRepos: RLMSessionLocalRepository.shared,
                                 userTimelineRepos: TKUserTimelineRepository.shared,
                                 tweetLocalRepos: RLMTweetLocalRepository.shared)
    }()

    // MARK: - BaseCircleViewController

    override func viewModel() -> BaseCircleViewModel {
        return self.vm
    }

}
