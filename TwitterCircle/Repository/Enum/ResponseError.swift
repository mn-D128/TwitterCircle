//
//  ResponseError.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

enum ResponseError: Error {
    case loginFailed(Error)
    case mismatchParameter(Error)
    case requestFaild(Error)
    case parseFailed
    case rateLimitExceeded
    case invalidOrExpiredToken
}
