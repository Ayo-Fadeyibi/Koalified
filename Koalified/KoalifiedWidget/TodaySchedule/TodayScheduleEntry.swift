//
//  TodayScheduleEntry.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import WidgetKit
import Foundation

struct TodayScheduleEntry: TimelineEntry {
    let date: Date
    let classes: [ClassSnapshot]
}
