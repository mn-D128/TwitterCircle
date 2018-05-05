//
//  TKUserRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift
import ObjectMapper
import Result

class TKUserRepository: TKBaseRepository<UserDto>,
    UserRepository {

    static let shared: UserRepository = TKUserRepository()

    private override init() {
        super.init()
    }

    // MARK: - TKBaseRepository

    override func parseJSON(_ json: String) -> UserDto? {
        let response: UserDto? = UserDto(JSONString: json)
        return response
    }

    // MARK: - Public

    func find(session: BaseSessionDto,
              userID: String,
              completion: @escaping (Result<UserDto, ResponseError>) -> Void) -> Disposable {
        let params: [String: Any] = [
            "user_id": userID
        ]

        return self.load(session: session,
                         url: "https://api.twitter.com/1.1/users/show.json",
                         params: params,
                         completion: completion)
    }

}
