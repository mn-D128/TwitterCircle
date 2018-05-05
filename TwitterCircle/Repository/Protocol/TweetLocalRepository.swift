//
//  TweetLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/17.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

protocol TweetLocalRepository {

    @discardableResult
    func append(contentsOf contents: [TweetDto]) -> Error?

    func count(_ userID: String, fromDate: Date?, toDate: Date?) -> Int
    func findAll(_ userID: String, fromDate: Date?, toDate: Date?) -> [TweetDto]
    func findFirst(_ userID: String) -> TweetDto?
    func findLast(_ userID: String) -> TweetDto?

}
