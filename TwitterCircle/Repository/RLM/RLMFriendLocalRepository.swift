//
//  RLMFriendRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/11.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMFriendLocalRepository: FriendLocalRepository {

    static let shared: FriendLocalRepository = RLMFriendLocalRepository()

    private let userAccessor = RLMAccessor<RLMUserEntity, String>()
    private let friendAccessor = RLMAccessor<RLMFriendResponseEntity, String>()

    private init() {}

    // MARK: - Private

    private func responseEntity(_ userID: String) -> RLMFriendResponseEntity? {
        return self.friendAccessor.object(userID)
    }

    // MARK: - FriendLocalRepository

    func nextCursor(_ userID: String) -> Int {
        return self.responseEntity(userID)?.nextCursor ?? 0
    }

    @discardableResult
    func append(userID: String, users: [UserDto], nextCursor: Int) -> Error? {
        var updateResponse: Bool = false
        var response: RLMFriendResponseEntity? = self.friendAccessor.object(userID)
        if response == nil {
            response = RLMFriendResponseEntity()
            response!.userID = userID

            updateResponse = true
        }

        return BaseRLMAccessor.write {
            response!.nextCursor = nextCursor

            for user: UserDto in users {
                let update: Bool = self.userAccessor.object(user.idStr) != nil
                let user: RLMUserEntity = RLMUserEntity(userDto: user)
                BaseRLMAccessor.add(user, update: update)

                response!.users.append(user)
            }

            BaseRLMAccessor.add(response!, update: updateResponse)
        }
    }

    func count(_ userID: String) -> Int {
        let count: Int = self.responseEntity(userID)?.users.count ?? 0
        return count
    }

    func findAll(_ userID: String, search: String?) -> [UserDto] {
        var result: [UserDto] = []

        guard let users: List<RLMUserEntity> = self.responseEntity(userID)?.users else {
            return result
        }

        if let search: String = search {
            let results: Results<RLMUserEntity> = users.filter("name CONTAINS[c] '\(search)' OR screenName CONTAINS[c] '\(search)'")

            for user: RLMUserEntity in results {
                result.append(user.userDto)
            }
        } else {
            for user: RLMUserEntity in users {
                result.append(user.userDto)
            }
        }

        return result
    }

    @discardableResult
    func deleteAll(_ userID: String) -> Error? {
        guard let response: RLMFriendResponseEntity = self.responseEntity(userID) else {
            return nil
        }

        return BaseRLMAccessor.write {
            BaseRLMAccessor.delete(response)
        }
    }

}
