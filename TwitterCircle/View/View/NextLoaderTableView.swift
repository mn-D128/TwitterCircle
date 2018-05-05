//
//  NextLoaderTableView.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit

class NextLoaderTableView: UITableView {

    private lazy var emptyView: UIView = {
        let view: UIView = UIView(frame: CGRect(x: 0.0,
                                                y: 0.0,
                                                width: self.frame.width,
                                                height: 0.0))
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth]
        view.backgroundColor = UIColor.clear

        return view
    }()

    private lazy var nextLoadView: NextLoadView = {
        var height: CGFloat = self.rowHeight
        if height == UITableViewAutomaticDimension {
            height = 44.0
        }

        let frame: CGRect = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: self.frame.width,
                                   height: height)
        let result: NextLoadView = NextLoadView(frame: frame)
        return result
    }()

    var didNextLoad: (() -> Void)?
    var hasNext: Bool {
        set {
            if newValue {
                super.tableFooterView = self.nextLoadView
            } else {
                super.tableFooterView = self.emptyView
            }
        }

        get {
            return super.tableFooterView != nil
        }
    }

    // MARK: - NSObject

    deinit {
        self.removeObserver(self,
                            forKeyPath: #keyPath(contentOffset),
                            context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }

        switch keyPath {
        case #keyPath(contentOffset):
            self.observeContentOffset(object: object, change: change)

        default:
            break
        }
    }

    // MARK: - UITableView

    override var tableFooterView: UIView? {
        set {
            assertionFailure("Can not use a tableFooterView in this class.")
        }

        get {
            assertionFailure("Can not use a tableFooterView in this class.")
            return nil
        }
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    // MARK: - Private

    private func initialize() {
        self.addObserver(self,
                         forKeyPath: #keyPath(contentOffset),
                         options: [.new],
                         context: nil)
    }

    private func observeContentOffset(object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?) {
        guard let change = change else {
            return
        }

        guard let contentOffset = change[NSKeyValueChangeKey.newKey] as? CGPoint else {
            return
        }

        self.confirmDisplayNextLoader(contentOffset)
    }

    private func confirmDisplayNextLoader(_ contentOffset: CGPoint) {
        guard let footerView: UIView = super.tableFooterView,
            footerView is NextLoadView else {
            return
        }

        let bottom: CGFloat = contentOffset.y + self.frame.height
        if footerView.frame.minY <= bottom {
            self.didNextLoad?()
        }
    }

    // MARK: -

    private class NextLoadView: UIView {

        private lazy var activityView: UIActivityIndicatorView = {
            let result = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            result.startAnimating()
            return result
        }()

        // MARK: - UIView

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.initialize()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.initialize()
        }

        // MARK: - Private

        private func initialize() {
            self.autoresizingMask = [
                .flexibleWidth
            ]

            self.activityView.center = CGPoint(x: self.frame.midX,
                                               y: self.frame.midY)
            self.addSubview(self.activityView)
        }

    }

}
