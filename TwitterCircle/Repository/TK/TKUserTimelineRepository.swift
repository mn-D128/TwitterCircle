//
//  TKUserTimelineRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Result

class TKUserTimelineRepository: TKBaseRepository<[TweetDto]>,
    UserTimelineRepository {

    static let shared: UserTimelineRepository = TKUserTimelineRepository()

    private override init() {
        super.init()
    }

    // MARK: - TKBaseRepository

    override func parseJSON(_ json: String) -> [TweetDto]? {
        let response: [TweetDto]? = [TweetDto](JSONString: json)
        return response
    }

    // MARK: - Public

    func find(session: BaseSessionDto,
              params: UserTimelineParams,
              completion: @escaping (Result<[TweetDto], ResponseError>) -> Void) -> Disposable {
        return self.load(session: session,
                         url: "https://api.twitter.com/1.1/statuses/user_timeline.json",
                         params: params.parameters,
                         completion: completion)
    }

}
