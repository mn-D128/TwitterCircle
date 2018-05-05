//
//  SessionLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

protocol SessionLocalRepository {

    func count() -> Int
    func find(userID: String) -> SessionDto?
    func findAll() -> [SessionDto]

    @discardableResult
    func append(_ session: SessionDto) -> Error?
    @discardableResult
    func delete(_ session: SessionDto) -> Error?

}
