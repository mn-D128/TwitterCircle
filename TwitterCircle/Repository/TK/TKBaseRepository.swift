//
//  TKBaseRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import TwitterKit
import RxSwift
import Result

class TKBaseRepository<Element> {

    public typealias E = Element

    // MARK: - Private

    private func loginObservableIfNeeded(_ session: BaseSessionDto) -> Observable<Any>? {
        let store: TWTRSessionStore = TWTRTwitter.sharedInstance().sessionStore
        if store.session(forUserID: session.userID) != nil {
            return nil
        }

        var isCancel: Bool = false

        return Observable<Any>.create { observer -> Disposable in
            let sessionEntity: TKSessionEntity = TKSessionEntity(baseSessionDto: session)
            let completion: TWTRSessionStoreSaveCompletion = { (session: TWTRAuthSession?, error: Error?) in
                if isCancel {
                    return
                }

                if let session: TWTRAuthSession = session {
                    observer.onNext(session)
                    observer.onCompleted()
                } else if let error: Error = error {
                    observer.onError(ResponseError.loginFailed(error))
                }
            }

            store.save(sessionEntity, completion: completion)

            return Disposables.create {
                isCancel = true
            }
        }
    }

    private func verboseResponseHeader(_ response: URLResponse?) {
        guard let response = response,
            let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            return
        }

        if let value: String = httpResponse.allHeaderFields["x-rate-limit-reset"] as? String,
            let timeInterval: TimeInterval = TimeInterval(value) {
            let date: Date = Date(timeIntervalSince1970: timeInterval)
            sLogger?.verbose("x-rate-limit-reset \(date)")
        }

        if let value: String = httpResponse.allHeaderFields["x-rate-limit-limit"] as? String {
            sLogger?.verbose("x-rate-limit-limit \(value)")
        }

        if let value: String = httpResponse.allHeaderFields["x-rate-limit-remaining"] as? String {
            sLogger?.verbose("x-rate-limit-remaining \(value)")
        }
    }

    private func determineApiResponseError(_ error: Error) -> ResponseError {
        let error: NSError = error as NSError
        let domain: String = error.domain

        if domain == "TwitterAPIErrorDomain" {
            let code: Int = error.code

            switch code {
            case 88: return ResponseError.rateLimitExceeded

            case 89: return ResponseError.invalidOrExpiredToken

            default: break
            }
        }

        return ResponseError.requestFaild(error)
    }

    private func apiObservable(session: BaseSessionDto, url: String, params: [String: Any]) -> Observable<Any> {
        return Observable<Any>.create { observer -> Disposable in
            let client: TWTRAPIClient = TWTRAPIClient(userID: session.userID)

            var error: NSError?
            let request: URLRequest = client.urlRequest(withMethod: "GET",
                                                        urlString: url,
                                                        parameters: params,
                                                        error: &error)

            let completion: TWTRNetworkCompletion = { [weak self] (response: URLResponse?, data: Data?, connectionError: Error?) in
                guard let weakSelf: TKBaseRepository = self else {
                    return
                }

                weakSelf.verboseResponseHeader(response)

                if let data: Data = data {
                    if let json: String = String(data: data, encoding: String.Encoding.utf8),
                        let response: E = weakSelf.parseJSON(json) {
                        observer.onNext(response)
                        observer.onCompleted()
                    } else {
                        observer.onError(ResponseError.parseFailed)
                    }
                } else if let connectionError: Error = connectionError {
                    let error: ResponseError = weakSelf.determineApiResponseError(connectionError)
                    observer.onError(error)
                }
            }

            if let error: Error = error {
                observer.onError(ResponseError.mismatchParameter(error))
                return Disposables.create()
            } else {
                let progress: Progress = client.sendTwitterRequest(request, completion: completion)
                return Disposables.create {
                    if progress.isFinished {
                        return
                    }

                    progress.cancel()
                }
            }
        }
    }

    // MARK: - Public

    func parseJSON(_ json: String) -> E? {
        return nil
    }

    func load(session: BaseSessionDto,
              url: String,
              params: [String: Any],
              completion: @escaping (Result<E, ResponseError>) -> Void) -> Disposable {
        var observable: Observable<Any>? = self.loginObservableIfNeeded(session)

        let observableApi: Observable = self.apiObservable(session: session,
                                                           url: url,
                                                           params: params)

        if observable != nil {
            observable = observable!.concat(observableApi)
        } else {
            observable = observableApi
        }

        let disposable: Disposable = observable!.subscribe(
            onNext: { (result: Any) in
                if let result = result as? E {
                    completion(Result.success(result))
                }
            },
            onError: { (error: Error) in
                completion(Result.failure(error as! ResponseError))
            }
        )

        return disposable
    }

}
