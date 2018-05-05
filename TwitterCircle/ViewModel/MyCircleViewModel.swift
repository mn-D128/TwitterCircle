//
//  MyCircleViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/20.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

class MyCircleViewModel: BaseCircleViewModel {

    // MARK: - BaseCircleViewModel

    override var session: SessionDto? {
        didSet {
            self.setUser(self.session?.user)
        }
    }

    override init(sessionLocalRepos: SessionLocalRepository,
                  userTimelineRepos: UserTimelineRepository,
                  tweetLocalRepos: TweetLocalRepository) {
        super.init(sessionLocalRepos: sessionLocalRepos,
                   userTimelineRepos: userTimelineRepos,
                   tweetLocalRepos: tweetLocalRepos)

        self.setUser(self.session?.user)
    }

}
