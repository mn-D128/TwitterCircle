//
//  UserRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/12.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import Result

protocol UserRepository {

    func find(session: BaseSessionDto,
              userID: String,
              completion: @escaping (Result<UserDto, ResponseError>) -> Void) -> Disposable

}
