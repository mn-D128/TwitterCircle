//
//  RLMHistoryLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/13.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMHistoryLocalRepository: HistoryLocalRepository {

    static let shared: HistoryLocalRepository = RLMHistoryLocalRepository()

    private let userAccessor = RLMAccessor<RLMUserEntity, String>()
    private let historyAccessor = RLMAccessor<RLMHistoryEntity, String>()

    private init() {}

    // MARK: HistoryLocalRepository

    func findAll(_ userID: String) -> [HistoryDto] {
        var result: [HistoryDto] = []

        let entities: Results<RLMHistoryEntity> = self.entities(userID)
        for entity: RLMHistoryEntity in entities {
            guard let history: HistoryDto = entity.historyDto else {
                continue
            }

            result.append(history)
        }

        return result
    }

    @discardableResult
    func append(_ history: HistoryDto) -> Error? {
        let historyEntity: RLMHistoryEntity = RLMHistoryEntity(historyDto: history)

        guard let userEntity: RLMUserEntity = historyEntity.user else {
            return nil
        }

        let updateUser: Bool = self.userAccessor.object(userEntity.idStr) != nil

        let updateHistory: Bool = self.historyAccessor.object(historyEntity.id) != nil

        return BaseRLMAccessor.write {
            BaseRLMAccessor.add(userEntity, update: updateUser)
            BaseRLMAccessor.add(historyEntity, update: updateHistory)
        }
    }

    @discardableResult
    func deleteAll(_ userID: String) -> Error? {
        let entities: Results<RLMHistoryEntity> = self.entities(userID)

        return BaseRLMAccessor.write {
            BaseRLMAccessor.delete(entities)
        }
    }

    @discardableResult
    func delete(_ history: HistoryDto) -> Error? {
        guard let entity: RLMHistoryEntity = self.historyAccessor.object(history.id) else {
            return nil
        }

        return BaseRLMAccessor.write {
            BaseRLMAccessor.delete(entity)
        }
    }

    func observe(_ userID: String, change: @escaping () -> Void) -> Any? {
        let block: (RealmCollectionChange<Results<RLMHistoryEntity>>) -> Void
            = { (changes: RealmCollectionChange<Results<RLMHistoryEntity>>) in
                switch changes {
                case .initial(_):
                    break

                case .update:
                    change()

                case .error:
                    break
                }
        }

        let entities: Results<RLMHistoryEntity> = self.entities(userID)
        let token: NotificationToken = entities.observe(block)

        return token
    }

    func invalidateObserve(_ token: Any?) {
        if let token = token as? NotificationToken {
            token.invalidate()
        }
    }

    // MARK: - Private

    private func entities(_ userID: String) -> Results<RLMHistoryEntity> {
        let entities: Results<RLMHistoryEntity>
            = self.historyAccessor.objects()
                .filter("userID = '\(userID)'")
                .sorted(byKeyPath: "updatedAt", ascending: false)
        return entities
    }

}
