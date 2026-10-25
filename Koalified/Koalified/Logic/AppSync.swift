//
//  AppSync.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftData
import WidgetKit

@MainActor
enum AppSync {
    static func dataChanged(in context: ModelContext) {
        try? context.save()
        let courses = (try? context.fetch(FetchDescriptor<Course>())) ?? []
        NotificationScheduler.reschedule(courses: courses)
        WidgetCenter.shared.reloadAllTimelines()
    }
}


