//
//  SampleData.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import Foundation

/// Hard-coded placeholder content used while screens are built and for onboarding help text.
enum SampleData {
    // Helper: today's date at a given time, e.g. today(at: 9, 30)
    static func today(at hour: Int, _ minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }

    /// Three sample classes for today.
    static let classEvents: [ClassEvent] = [
        ClassEvent(courseCode: "CSSE1001", kind: .lecture, room: "50-201",
                   start: today(at: 9), end: today(at: 10)),
        ClassEvent(courseCode: "MATH1051", kind: .tutorial, room: "67-105",
                   start: today(at: 11), end: today(at: 12)),
        ClassEvent(courseCode: "ECON1010", kind: .lecture, room: "14-212",
                   start: today(at: 13), end: today(at: 14))
    ]
    
    /// The steps shown on the "find your timetable" help screen.
    static let steps = [
        "Open your timetable on UQ's website and sign in there.",
        "Look for the option to export or download your calendar (an .ics file, or a calendar link).",
        "Copy the link, or save the file to your phone.",
        "Come back here and paste the link, or choose the file."
    ]
    
    static let profileLinks = [
        "Settings",
        "Import timetable (.ics)",
        "Degree program",
        "Home Screen widgets",
        "Export and backup",
        "Help and feedback"
    ]
    
    static let grades = [
        "Grade 1",
        "Grade 2",
        "Grade 3",
        "Grade 4",
        "Grade 5",
        "Grade 6",
        "Grade 7",
    ]
}
