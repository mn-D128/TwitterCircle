//
//  FriendRepository.swift
//  TwitterCircle
//
//  Created by mn(D128). on 2018/04/06.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import Result
import RxSwift

protocol FriendRepository {

    func find(session: BaseSessionDto,
              cursor: Int?,
              count: Int?,
              completion: @escaping (Result<FriendResponseDto, ResponseError>) -> Void) -> Disposable

}
