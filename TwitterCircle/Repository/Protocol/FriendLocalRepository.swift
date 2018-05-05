//
//  FriendLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/11.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

protocol FriendLocalRepository {

    func nextCursor(_ userID: String) -> Int

    func count(_ userID: String) -> Int

    func findAll(_ userID: String, search: String?) -> [UserDto]

    @discardableResult
    func append(userID: String, users: [UserDto], nextCursor: Int) -> Error?

    @discardableResult
    func deleteAll(_ userID: String) -> Error?

}
