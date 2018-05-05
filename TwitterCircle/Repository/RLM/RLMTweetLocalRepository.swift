//
//  RLMTweetLocalRepository.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/17.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation
import RealmSwift

class RLMTweetLocalRepository: TweetLocalRepository {

    static let shared: TweetLocalRepository = RLMTweetLocalRepository()

    private let userAccessor = RLMAccessor<RLMUserEntity, String>()
    private let retweetedStatusAccessor = RLMAccessor<RLMRetweetedStatusEntity, String>()
    private let mediaAccessor = RLMAccessor<RLMMediaEntity, String>()
    private let tweetAccessor = RLMAccessor<RLMTweetEntity, String>()

    private lazy var tweets: Results<RLMTweetEntity> = {
        return self.tweetAccessor.objects()
    }()

    // MARK: - Private

    private func resultsOfUserID(_ userID: String, fromDate: Date?, toDate: Date?) -> Results<RLMTweetEntity> {
        var result: Results<RLMTweetEntity> = self.tweets.filter("user.idStr = %@", userID)

        if let fromDate: Date = fromDate {
            result = result.filter("%@ <= createdAt", fromDate)
        }

        if let toDate: Date = toDate {
            result = result.filter("createdAt <= %@", toDate)
        }

        result = result.sorted(byKeyPath: "createdAt", ascending: false)

        return result
    }

    // MARK: - TweetLocalRepository

    @discardableResult
    func append(contentsOf contents: [TweetDto]) -> Error? {
        if contents.isEmpty {
            return nil
        }

        return BaseRLMAccessor.write {
            for tweet: TweetDto in contents {
                let tweetEntity: RLMTweetEntity = RLMTweetEntity(tweetDto: tweet)
                let userEntity: RLMUserEntity = tweetEntity.user!
                let oldTweetEntity: RLMTweetEntity? = self.tweetAccessor.object(tweet.idStr)

                let updateUser: Bool = self.userAccessor.object(userEntity.idStr) != nil
                BaseRLMAccessor.add(userEntity, update: updateUser)

                if let retweetedStatusEntity: RLMRetweetedStatusEntity = tweetEntity.retweetedStatus {
                    let userEntity: RLMUserEntity = retweetedStatusEntity.user!

                    let updateUser: Bool = self.userAccessor.object(userEntity.idStr) != nil
                    BaseRLMAccessor.add(userEntity, update: updateUser)

                    let updateRetweetedStatus: Bool = self.retweetedStatusAccessor.object(retweetedStatusEntity.idStr) != nil
                    BaseRLMAccessor.add(retweetedStatusEntity, update: updateRetweetedStatus)
                }

                if let extendedEntitiesEntity: RLMExtendedEntitiesEntity = tweetEntity.extendedEntities {
                    for i in 0 ..< extendedEntitiesEntity.medias.count {
                        let media: RLMMediaEntity = extendedEntitiesEntity.medias[i]

                        if let oldMedia: RLMMediaEntity = self.mediaAccessor.object(media.idStr) {
                            oldMedia.sizes?.large = media.sizes?.large
                            oldMedia.sizes?.small = media.sizes?.small
                            oldMedia.sizes?.thumb = media.sizes?.thumb
                            oldMedia.sizes?.medium = media.sizes?.medium

                            oldMedia.mediaUrlHttps = media.mediaUrlHttps
                            extendedEntitiesEntity.medias[i] = oldMedia
                        } else {
                            if let sizes: RLMSizesEntity = media.sizes {
                                if let large: RLMSizeEntity = sizes.large {
                                    BaseRLMAccessor.add(large, update: false)
                                }

                                if let small: RLMSizeEntity = sizes.small {
                                    BaseRLMAccessor.add(small, update: false)
                                }

                                if let medium: RLMSizeEntity = sizes.medium {
                                    BaseRLMAccessor.add(medium, update: false)
                                }

                                if let thumb: RLMSizeEntity = sizes.thumb {
                                    BaseRLMAccessor.add(thumb, update: false)
                                }

                                BaseRLMAccessor.add(sizes, update: false)
                            }

                            BaseRLMAccessor.add(media, update: false)
                        }
                    }

                    if let oldExtendedEntitiesEntity: RLMExtendedEntitiesEntity = oldTweetEntity?.extendedEntities {
                        oldExtendedEntitiesEntity.medias.removeAll()
                        oldExtendedEntitiesEntity.medias.append(objectsIn: extendedEntitiesEntity.medias)
                    } else {
                        BaseRLMAccessor.add(extendedEntitiesEntity, update: false)
                    }
                }

                let updateTweet: Bool = oldTweetEntity != nil
                BaseRLMAccessor.add(tweetEntity, update: updateTweet)
            }
        }
    }

    func count(_ userID: String, fromDate: Date? = nil, toDate: Date? = nil) -> Int {
        return self.resultsOfUserID(userID, fromDate: fromDate, toDate: toDate).count
    }

    func findAll(_ userID: String, fromDate: Date? = nil, toDate: Date? = nil) -> [TweetDto] {
        let tweets: Results<RLMTweetEntity> = self.resultsOfUserID(userID, fromDate: fromDate, toDate: toDate)

        var result: [TweetDto] = [TweetDto]()

        for tweet: RLMTweetEntity in tweets {
            guard let tweetDto: TweetDto = tweet.tweetDto else {
                continue
            }

            result.append(tweetDto)
        }

        return result
    }

    func findFirst(_ userID: String) -> TweetDto? {
        guard let tweet: RLMTweetEntity
            = self.tweets
                .filter("user.idStr = %@", userID)
                .sorted(byKeyPath: "createdAt", ascending: false).first else {
            return nil
        }

        return tweet.tweetDto
    }

    func findLast(_ userID: String) -> TweetDto? {
        guard let tweet: RLMTweetEntity
            = self.tweets
                .filter("user.idStr = %@", userID)
                .sorted(byKeyPath: "createdAt", ascending: false).last else {
            return nil
        }

        return tweet.tweetDto
    }

}
