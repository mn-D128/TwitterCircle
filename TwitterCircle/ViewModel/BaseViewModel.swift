//
//  BaseViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/22.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class BaseViewModel {

    // MARK: -

    private let toastErrorMessage: Variable<String?> = Variable<String?>(nil)
    lazy var toastErrorMessageDriver: SharedSequence = {
        return self.toastErrorMessage.asDriver().filterNil()
    }()

    func setToastErrorMessage(_ message: String) {
        self.toastErrorMessage.value = message
    }

    // MARK: -

    private let isProgressHidden: Variable<Bool> = Variable<Bool>(true)
    lazy var isProgressHiddenDriver: SharedSequence = {
        return self.isProgressHidden.asDriver()
    }()

    func setProgressHidden(_ isHidden: Bool) {
        self.isProgressHidden.value = isHidden
    }

}
