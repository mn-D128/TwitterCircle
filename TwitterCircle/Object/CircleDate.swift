//
//  CircleDate.swift
//  TwitterCircle
//
//  Created by mn(D128) on 2018/04/08.
//  Copyright © 2018年 mn(D128). All rights reserved.
//

import Foundation

struct CircleDate {
    let year: Int
    let month: Int
    let day: Int

    // MARK: -

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(date: Date) {
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)

        self.year = cal.component(.year, from: date)
        self.month = cal.component(.month, from: date)
        self.day = cal.component(.day, from: date)
    }

    // MARK: - Public

    static var now: CircleDate {
        return CircleDate(date: Date())
    }

    var beginDate: Date? {
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        return self.beginDate(cal)
    }

    var endDate: Date? {
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard let date: Date = self.beginDate(cal) else {
            return nil
        }

        let result: Date? = cal.date(bySettingHour: 23,
                                     minute: 59,
                                     second: 59,
                                     of: date)
        return result
    }

    var previousDate: CircleDate? {
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard let beginDate: Date = self.beginDate(cal) else {
            return nil
        }

        guard let previousDate: Date = cal.date(byAdding: .day,
                                                value: -1,
                                                to: beginDate) else {
            return nil
        }

        let year: Int = cal.component(.year, from: previousDate)
        let month: Int = cal.component(.month, from: previousDate)
        let day: Int = cal.component(.day, from: previousDate)

        return CircleDate(year: year,
                          month: month,
                          day: day)
    }

    var nextDate: CircleDate? {
        let cal: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard let beginDate: Date = self.beginDate(cal) else {
            return nil
        }

        guard let nextDate: Date = cal.date(byAdding: .day,
                                            value: 1,
                                            to: beginDate) else {
            return nil
        }

        return CircleDate(date: nextDate)
    }

    // MARK: - Private

    private func beginDate(_ cal: Calendar) -> Date? {
        var result: Date = Date()

        // 年を調整
        let year: Int = cal.component(.year, from: result)
        if let date: Date = cal.date(byAdding: .year,
                                     value: (self.year - year),
                                     to: result) {
            result = date
        } else {
            return nil
        }

        // 月を調整
        let month: Int = cal.component(.month, from: result)
        if let date: Date = cal.date(byAdding: .month,
                                     value: (self.month - month),
                                     to: result) {
            result = date
        } else {
            return nil
        }

        // 日を調整
        let day: Int = cal.component(.day, from: result)
        if let date: Date = cal.date(byAdding: .day,
                                     value: (self.day - day),
                                     to: result) {
            result = date
        } else {
            return nil
        }

        // 時分秒を調整
        result = cal.startOfDay(for: result)

        return result
    }

}
