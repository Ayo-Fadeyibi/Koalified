//
//  parseICSDate.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 30/10/2026.
//

import Foundation

//This takes the DSTART and DEND string from the .ics file and turn it into an actual date
func parseICSDate(_ text: String, timeZone: TimeZone = TimeZone(identifier: "Australia/Brisbane")!) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")

    if text.count == 16, text.hasSuffix("Z") {
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    } else if text.count == 15 {
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        formatter.timeZone = timeZone
    } else if text.count == 8 {
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = timeZone
    } else {
        return nil
    }

    return formatter.date(from: text)
}

