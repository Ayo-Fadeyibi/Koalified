//
//  NotificationScheduler.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import UserNotifications

enum NotificationScheduler {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }
    
    struct Reminder {
        let id: String
        let fireDate: Date
        let title: String
        let body: String
    }

    static func reminders(for courses: [Course]) -> [Reminder] {
        let cal = Calendar.current
        var result: [Reminder] = []

        for course in courses {
            for item in course.assessments where item.mark == nil {
                guard let dayBefore = cal.date(byAdding: .day, value: -1, to: item.dueDate),
                      let fire = cal.date(bySettingHour: 9, minute: 0, second: 0, of: dayBefore),
                      fire > .now
                else { continue }

                result.append(Reminder(
                    id: "due-\(course.courseCode)-\(item.title)-\(item.dueDate.timeIntervalSince1970)",
                    fireDate: fire,
                    title: "\(item.title) is due tomorrow",
                    body: "\(course.courseCode) · \(Int(item.weight))% of your grade"
                ))
            }
        }
        return result
    }

    static func reschedule(courses: [Course]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let upcoming = reminders(for: courses)
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(60)

        for reminder in upcoming {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default

            let parts = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            center.add(UNNotificationRequest(identifier: reminder.id,
                                             content: content, trigger: trigger))
        }
        center.getPendingNotificationRequests { print("Scheduled reminders:", $0.count) }
    }
}


