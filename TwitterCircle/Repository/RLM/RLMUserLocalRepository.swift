//
//  RLMUserLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMUserLocalRepository: UserLocalRepository {

    static let shared: UserLocalRepository = RLMUserLocalRepository()

    private let accessor = RLMAccessor<RLMUserEntity, String>()

    private init() {}

    // MARK: - UserLocalRepository

    func find(_ userID: String) -> UserDto? {
        guard let entity: RLMUserEntity = self.accessor.object(userID) else {
            return nil
        }

        return entity.userDto
    }

    @discardableResult
    func append(_ user: UserDto) -> Error? {
        let entity: RLMUserEntity = RLMUserEntity(userDto: user)

        let update: Bool = self.accessor.object(user.idStr) != nil

        return BaseRLMAccessor.write {
            BaseRLMAccessor.add(entity, update: update)
        }
    }

}
