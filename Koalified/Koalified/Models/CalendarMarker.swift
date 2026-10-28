//
//  CalendarMarker.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import Foundation

/// A dated event shown on the calendar: an assessment deadline or a course drop date.
struct CalendarMarker: Identifiable {
    /// `deadline` is an assessment due date; `drop` is a census or last-day-to-drop date.
    enum Kind { case deadline, drop }

    let id = UUID()
    let date: Date
    let kind: Kind
    let title: String
    let courseCode: String

    /// Flattens every course's assessments, census date and last drop date into one list of markers.
    static func markers(from courses: [Course]) -> [CalendarMarker] {
        courses.flatMap { course in
            var items = course.assessments.map {
                CalendarMarker(date: $0.dueDate, kind: .deadline,
                               title: $0.title, courseCode: course.courseCode)
            }
            if let census = course.censusDate {
                items.append(CalendarMarker(date: census, kind: .drop,
                                            title: "Census date", courseCode: course.courseCode))
            }
            if let drop = course.lastDropDate {
                items.append(CalendarMarker(date: drop, kind: .drop,
                                            title: "Last day to drop", courseCode: course.courseCode))
            }
            return items
        }
    }
}
