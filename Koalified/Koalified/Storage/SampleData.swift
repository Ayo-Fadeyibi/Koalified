//
//  SampleData.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import Foundation

enum SampleData {
    // Helper: today's date at a given time, e.g. today(at: 9, 30)
    static func today(at hour: Int, _ minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }

    static let classEvents: [ClassEvent] = [
        ClassEvent(courseCode: "CSSE1001", kind: "Lecture", room: "50-201",
                   start: today(at: 9), end: today(at: 10)),
        ClassEvent(courseCode: "MATH1051", kind: "Tutorial", room: "67-105",
                   start: today(at: 11), end: today(at: 12)),
        ClassEvent(courseCode: "ECON1010", kind: "Lecture", room: "14-212",
                   start: today(at: 13), end: today(at: 14))
    ]
}
