//
//  UIViewController+BaseViewModel.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/22.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit
import ToastSwiftFramework
import RxSwift
import MBProgressHUD

extension UIViewController {

    func toastErrorMessageBindViewModel(_ vm: BaseViewModel, disposeBag: DisposeBag) {
        vm.toastErrorMessageDriver
            .drive(onNext: { [weak self] (message: String) in
                guard let weakSelf: UIViewController = self else {
                    return
                }

                weakSelf.view.hideToast()
                weakSelf.view.makeRedToast(message)
            })
            .disposed(by: disposeBag)
    }

    func progressHiddenBindViewModel(_ vm: BaseViewModel, disposeBag: DisposeBag) {
        vm.isProgressHiddenDriver
            .drive(onNext: { [weak self] (isHidden: Bool) in
                guard let weakSelf: UIViewController = self else {
                    return
                }

                if isHidden {
                    MBProgressHUD.hide(for: weakSelf.view, animated: true)
                } else {
                    if MBProgressHUD(for: weakSelf.view) == nil {
                        MBProgressHUD.showAdded(to: weakSelf.view, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func bindViewModel(_ vm: BaseViewModel, disposeBag: DisposeBag) {
        self.toastErrorMessageBindViewModel(vm, disposeBag: disposeBag)
        self.progressHiddenBindViewModel(vm, disposeBag: disposeBag)
    }

}
