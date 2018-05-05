//
//  TKFriendRepository.swift
//  TwitterCircle
//
//  Created by mn(D128). on 2018/04/06.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift
import ObjectMapper
import Result

class TKFriendRepository: TKBaseRepository<FriendResponseDto>,
    FriendRepository {

    static let shared: FriendRepository = TKFriendRepository()

    private override init() {
        super.init()
    }

    // MARK: - TKBaseRepository

    override func parseJSON(_ json: String) -> FriendResponseDto? {
        let response: FriendResponseDto? = FriendResponseDto(JSONString: json)
        return response
    }

    // MARK: - Public

    func find(session: BaseSessionDto,
              cursor: Int? = nil,
              count: Int? = nil,
              completion: @escaping (Result<FriendResponseDto, ResponseError>) -> Void) -> Disposable {
        var params: [String: Any] = [String: Any]()

        if let cursor = cursor {
            params["cursor"] = cursor.description
        }

        if let count = count {
            params["count"] = count.description
        }

        return self.load(session: session,
                         url: "https://api.twitter.com/1.1/friends/list.json",
                         params: params,
                         completion: completion)
    }

}
