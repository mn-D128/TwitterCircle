//
//  RLMSessionLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/16.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMSessionLocalRepository: SessionLocalRepository {

    static let shared: SessionLocalRepository = RLMSessionLocalRepository()

    private let sessionAccessor = RLMAccessor<RLMSessionEntity, String>()
    private let userAccessor = RLMAccessor<RLMUserEntity, String>()

    private lazy var sessions: Results<RLMSessionEntity> = {
        return self.sessionAccessor.objects()
    }()

    private init() {}

    func findAll() -> [SessionDto] {
        var result: [SessionDto] = [SessionDto]()

        for session: RLMSessionEntity in self.sessions {
            if let session: SessionDto = session.sessionDto {
                result.append(session)
            }
        }

        return result
    }

    func count() -> Int {
        return self.sessions.count
    }

    func find(userID: String) -> SessionDto? {
        guard let sessionEntity: RLMSessionEntity = self.object(userID) else {
            return nil
        }

        return sessionEntity.sessionDto
    }

    @discardableResult
    func append(_ session: SessionDto) -> Error? {
        let sessionEntity: RLMSessionEntity = RLMSessionEntity(sessionDto: session)

        guard let userEntity: RLMUserEntity = sessionEntity.user else {
            return nil
        }

        let updateUser: Bool = self.userAccessor.object(userEntity.idStr) != nil

        let updateSession: Bool = self.object(session.userID) != nil

        return BaseRLMAccessor.write {
            BaseRLMAccessor.add(userEntity, update: updateUser)
            BaseRLMAccessor.add(sessionEntity, update: updateSession)
        }
    }

    @discardableResult
    func delete(_ session: SessionDto) -> Error? {
        guard let sessionEntity: RLMSessionEntity = self.object(session.userID) else {
            return nil
        }

        return BaseRLMAccessor.write {
            BaseRLMAccessor.delete(sessionEntity)
        }
    }

    // MARK: - Private

    private func object(_ userID: String) -> RLMSessionEntity? {
        return self.sessionAccessor.object(userID)
    }

}
