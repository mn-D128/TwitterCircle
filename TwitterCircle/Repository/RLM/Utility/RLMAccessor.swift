//
//  RLMAccessor.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/18.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class BaseRLMAccessor {

    private static let schemaVersion: UInt64 = 0

    private static var _realm: Realm?
    private static var realm: Realm {
        if let realm: Realm = _realm {
            return realm
        }

        let migrationBlock: MigrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
            self.migration(migration, oldSchemaVersion: oldSchemaVersion)
        }

        let config: Realm.Configuration
            = Realm.Configuration(schemaVersion: schemaVersion,
                                  migrationBlock: migrationBlock)

        let realm: Realm = try! Realm(configuration: config)
        _realm = realm

        return realm
    }

    fileprivate var realm: Realm {
        return type(of: self).realm
    }

    // MARK: - Private

    private static func migration(_ migration: Migration, oldSchemaVersion: UInt64) {
    }

    // MARK: - Public

    static func add(_ object: Object, update: Bool) {
        realm.add(object, update: update)
    }

    static func delete(_ object: Object) {
        realm.delete(object)
    }

    static func delete<Element>(_ objects: Results<Element>) where Element: Object {
        realm.delete(objects)
    }

    @discardableResult
    static func write(_ block: () throws -> Void) -> Error? {
        realm.beginWrite()

        do {
            try block()
        } catch let error {
            if realm.isInWriteTransaction {
                realm.cancelWrite()
            }

            return error
        }

        do {
            try realm.commitWrite()
        } catch let error {
            realm.cancelWrite()

            return error
        }

        return nil
    }

}

class RLMAccessor<T: Object, PK>: BaseRLMAccessor {

    func objects() -> Results<T> {
        return self.realm.objects(T.self)
    }

    func object(_ primaryKey: PK) -> T? {
        return self.realm.object(ofType: T.self, forPrimaryKey: primaryKey)
    }

}
