//
//  AppSync.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftData
import WidgetKit

/// Keeps the outside world in step with the database: notifications and the widget.
@MainActor
enum AppSync {
    /// Call after any change to courses or assessments. Saves the context, rebuilds
    /// the due-date reminders and tells WidgetKit to refresh the widget.
    static func dataChanged(in context: ModelContext) {
        try? context.save()
        let courses = (try? context.fetch(FetchDescriptor<Course>())) ?? []
        NotificationScheduler.reschedule(courses: courses)
        WidgetCenter.shared.reloadAllTimelines()
    }
}


