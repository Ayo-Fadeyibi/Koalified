//
//  CalendarMath.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import Foundation
import SwiftUI

enum CalendarMath {
    static func days(in month: Date) -> [Date?] {
        var cal = Calendar.current
        cal.firstWeekday = 2                       // 2 = Monday (1 = Sunday)

        guard let interval = cal.dateInterval(of: .month, for: month),
              let dayCount = cal.range(of: .day, in: .month, for: month)?.count
        else { return [] }

        let weekdayOfFirst = cal.component(.weekday, from: interval.start)
        let leadingBlanks = (weekdayOfFirst - cal.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            result.append(cal.date(byAdding: .day, value: offset, to: interval.start))
        }
        return result
    }
}

#Preview {
    let days = CalendarMath.days(in: .now)
    let blanks = days.filter { $0 == nil }.count
    Text("\(days.count) items, \(blanks) blanks")
}
