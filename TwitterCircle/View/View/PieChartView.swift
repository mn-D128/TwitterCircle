//
//  PieChartView.swift
//  TwitterCircle
//
//  Created by mn(D128)on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import UIKit

class PieChartView: UIView {

    // 固定値
    private let degreePerHour: Double = 360.0 / 24.0
    private let degreePerSec: Double = 360.0 / (60.0 * 60.0 * 24.0)
    private let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)

    // 調整値
    private let labelMargin: Double = 10.0
    private let labelFont: UIFont = UIFont.systemFont(ofSize: 14.0)
    private let animDuration: CFTimeInterval = 1.0

    // 直径
    private var diameter: CGFloat = 0.0

    // アニメーション用
    private var displayLink: CADisplayLink?
    private var currentAnimDegree: Double = 360.0
    private var beginAnimTimestamp: CFTimeInterval = 0.0

    var tweets: [TweetDto]? {
        didSet {
            self.selectedTweets = nil
            self.setNeedsDisplay()
        }
    }

    var selectedTweets: [TweetDto]? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    // MARK: - UIView

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateDiameter()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            self.displayLink?.invalidate()
            self.displayLink = nil
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let ovalRect: CGRect = CGRect(x: (rect.size.width - self.diameter) / 2.0,
                                      y: (rect.size.height - self.diameter) / 2.0,
                                      width: self.diameter,
                                      height: self.diameter)
        // 円
        let oval: UIBezierPath = UIBezierPath(ovalIn: ovalRect)
        // stroke 色の設定
        UIColor.black.setStroke()
        // ライン幅
        oval.lineWidth = 1.0 / UIScreen.main.scale
        // 描画
        oval.stroke()

        // 半径
        let r: Double = Double(self.diameter / 2.0)
        // 中心
        let center: CGPoint = CGPoint(x: rect.midX,
                                      y: rect.midY)

        // ラベル描画
        self.drawHourLabel(radius: r, center: center)

        guard var tweets: [TweetDto] = self.tweets else {
            return
        }

        for i: Int in (0 ..< tweets.count).reversed() {
            let tweet: TweetDto = tweets[i]

            if let selectedTweets: [TweetDto] = self.selectedTweets,
                selectedTweets.index(where: { (selectedTweet: TweetDto) -> Bool in
                    return selectedTweet == tweet
                }) != nil {
                tweets.remove(at: i)
            }
        }

        UIColor.green.setStroke()
        self.drawTweet(tweets, radius: r, center: center)

        if let selectedTweets: [TweetDto] = self.selectedTweets {
            UIColor.red.setStroke()
            self.drawTweet(selectedTweets, radius: r, center: center)
        }
    }

    // MARK: - Public

    func startAnimation() {
        self.currentAnimDegree = 0.0
        self.beginAnimTimestamp = 0.0

        self.displayLink?.invalidate()
        self.displayLink = CADisplayLink(target: self,
                                                       selector: #selector(displayLinkFire(_:)))
        self.displayLink?.add(to: RunLoop.current,
                              forMode: RunLoopMode.commonModes)
    }

    // MARK: - Private

    private func drawHourLabel(radius: Double, center: CGPoint) {
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: self.labelFont,
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]

        for i: Int in 0 ..< 24 {
            let text: NSString = "\(i)" as NSString
            let size: CGSize = text.size(withAttributes: attributes)

            let degree: Double = Double(i) * self.degreePerHour
            let point: CGPoint = self.pointFromDegree(degree,
                                                      radius: radius + self.labelMargin,
                                                      center: center)

            var drawPoint: CGPoint = CGPoint.zero
            if i == 0 {
                drawPoint.x = point.x - size.width.round / 2.0
                drawPoint.y = point.y - size.height.round
            } else if 0 < i && i < 6 {
                drawPoint.x = point.x
                drawPoint.y = point.y - size.height.round
            } else if i == 6 {
                drawPoint.x = point.x
                drawPoint.y = point.y - size.height.round / 2.0
            } else if 6 < i && i < 12 {
                drawPoint.x = point.x
                drawPoint.y = point.y
            } else if i == 12 {
                drawPoint.x = point.x - size.width.round / 2.0
                drawPoint.y = point.y
            } else if 12 < i && i < 18 {
                drawPoint.x = point.x - size.width.round
                drawPoint.y = point.y
            } else if i == 18 {
                drawPoint.x = point.x - size.width.round
                drawPoint.y = point.y - size.height.round / 2.0
            } else if 18 < i {
                drawPoint.x = point.x - size.width.round
                drawPoint.y = point.y - size.height.round
            }

            text.draw(at: drawPoint,
                      withAttributes: attributes)
        }
    }

    private func pointFromDegree(_ degree: Double, radius: Double, center: CGPoint) -> CGPoint {
        let radian: Double = degree * Double.pi / 180.0

        let x: CGFloat = CGFloat(radius * sin(radian))
        let y: CGFloat = CGFloat(radius * cos(radian))

        return CGPoint(x: center.x + x,
                       y: center.y - y)
    }

    private func updateDiameter() {
        let rect: CGRect = self.bounds

        let calcAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: self.labelFont
        ]

        let labelWidth: CGFloat = max(("\(6)" as NSString).size(withAttributes: calcAttributes).width.round,
                                      ("\(18)" as NSString).size(withAttributes: calcAttributes).width.round)

        self.diameter = min(rect.size.width - (labelWidth + self.labelMargin.cgFloat) * 2.0,
                            rect.size.height - (self.labelFont.lineHeight + self.labelMargin.cgFloat) * 2.0)
    }

    private func drawTweet(_ tweets: [TweetDto], radius: Double, center: CGPoint) {
        for tweet: TweetDto in tweets {
            let createdAt: Date = tweet.createdAt
            let hour: Int = self.calendar.component(.hour, from: createdAt)
            let min: Int = self.calendar.component(.minute, from: createdAt)
            let sec: Int = self.calendar.component(.second, from: createdAt)

            let degree: Double = Double(hour * 60 * 60 + min * 60 + sec) * self.degreePerSec

            if self.currentAnimDegree < degree {
                continue
            }

            let point: CGPoint = self.pointFromDegree(degree,
                                                      radius: radius,
                                                      center: center)
            let line: UIBezierPath = UIBezierPath()
            line.move(to: center)
            line.addLine(to: point)
            line.close()
            line.lineWidth = 1.0 / UIScreen.main.scale
            line.stroke()
        }
    }

    // MARK: - CADisplayLink

    @objc private func displayLinkFire(_ displayLink: CADisplayLink) {
        let timestamp: CFTimeInterval = displayLink.timestamp

        if self.beginAnimTimestamp == 0.0 {
            let duration: CFTimeInterval = displayLink.duration
            self.beginAnimTimestamp = timestamp - duration
        }

        let progress: CFTimeInterval = (timestamp - self.beginAnimTimestamp) / self.animDuration

        self.currentAnimDegree = Double(360.0 * progress)

        self.setNeedsDisplay()

        if 360.0 < self.currentAnimDegree {
            displayLink.invalidate()
            if self.displayLink == displayLink {
                self.displayLink = nil
            }
        }
    }

}
