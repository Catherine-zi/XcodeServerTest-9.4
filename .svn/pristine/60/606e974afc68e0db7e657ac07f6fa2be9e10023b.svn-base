//
//  TimeInterval+FormatedString.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/7/12.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import Foundation

extension TimeInterval {
    func getFormattedString() -> String {
        let now = Date().timeIntervalSince1970
        let interval = now - self
        var formattedString = ""
        if interval < 3600 {
            let minutes = interval / 60
            let minutesStr = String(minutes).split(separator: ".")
            if minutesStr.count > 0 {
                formattedString = String(minutesStr[0]) + SWLocalizedString(key: "minutes_ago")
            }
        } else if interval < 3600 * 24 {
            let hours = interval / 3600
            let hoursStr = String(hours).split(separator: ".")
            if hoursStr.count > 0 {
                formattedString = String(hoursStr[0]) + SWLocalizedString(key: "hours_ago")
            }
        } else if interval < 3600 * 24 * 30 {
            let days = interval / 3600 / 24
            let daysStr = String(days).split(separator: ".")
            if daysStr.count > 0 {
                formattedString = String(daysStr[0]) + SWLocalizedString(key: "days_ago")
            }
        } else if interval < 3600 * 24 * 365 {
            let months = interval / 3600 / 24 / 30
            let monthsStr = String(months).split(separator: ".")
            if monthsStr.count > 0 {
                formattedString = String(monthsStr[0]) + SWLocalizedString(key: "months_ago")
            }
        } else {
            let years = interval / 3600 / 24 / 365
            let yearsStr = String(years).split(separator: ".")
            if yearsStr.count > 0 {
                formattedString = String(yearsStr[0]) + SWLocalizedString(key: "years_ago")
            }
        }
        return formattedString
    }
}
