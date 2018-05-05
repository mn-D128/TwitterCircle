//
//  CircleViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CircleViewModel: BaseCircleViewModel {

    private let close: Variable<Void?> = Variable<Void?>(nil)
    lazy var closeDriver: SharedSequence = {
        return self.close.asDriver().filterNil()
    }()

    // MARK: - BaseCircleViewModel

    override var session: SessionDto? {
        didSet {
            self.close.value = Void()
        }
    }

}
