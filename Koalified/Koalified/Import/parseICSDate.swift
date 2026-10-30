//
//  parseICSDate.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 30/10/2026.
//

import Foundation

func parseICSDate(_ text: String, timeZone: TimeZone = TimeZone(identifier: "Australia/Brisbane")!) -> Date? {
guard text.count == 15 else { return nil }
let formatter = DateFormatter()
formatter.dateFormat = "yyyyMMdd'T'HHmmss"
formatter.timeZone = timeZone
formatter.locale = Locale(identifier: "en_US_POSIX")
let date = formatter.date(from: text)
return date
}
