//
//  UserTimelineRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import Result
import RxSwift

struct UserTimelineParams {

    let userID: String
    let sinceID: String?
    let maxID: String?
    let count: Int?

    init(userID: String, sinceID: String? = nil, maxID: String? = nil, count: Int? = nil) {
        self.userID = userID
        self.sinceID = sinceID
        self.maxID = maxID
        self.count = count
    }

    var parameters: [String: Any] {
        var result: [String: Any] = [
            "user_id": userID
        ]

        if let sinceID: String = sinceID {
            result["since_id"] = sinceID
        }

        if let maxID: String = maxID {
            result["max_id"] = maxID
        }

        if let count: Int = count {
            result["count"] = count.description
        }

        return result
    }

}

protocol UserTimelineRepository {

    func find(session: BaseSessionDto,
              params: UserTimelineParams,
              completion: @escaping (Result<[TweetDto], ResponseError>) -> Void) -> Disposable

}
