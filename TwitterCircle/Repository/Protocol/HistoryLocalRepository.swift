//
//  HistoryLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/13.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

protocol HistoryLocalRepository {

    func findAll(_ userID: String) -> [HistoryDto]

    @discardableResult
    func append(_ history: HistoryDto) -> Error?

    @discardableResult
    func deleteAll(_ userID: String) -> Error?

    @discardableResult
    func delete(_ history: HistoryDto) -> Error?

    func observe(_ userID: String, change: @escaping () -> Void) -> Any?
    func invalidateObserve(_ token: Any?)

}
