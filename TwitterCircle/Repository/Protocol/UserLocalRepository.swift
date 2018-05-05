//
//  UserLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

protocol UserLocalRepository {

    func find(_ userID: String) -> UserDto?

    @discardableResult
    func append(_ user: UserDto) -> Error?

}
