//
//  TimetableWeek.swift
//  Koalified
//

import Foundation

/// The date maths behind `WeekGridView`: which days and hours to show, the title, and where each class sits.
struct TimetableWeek {
    let sessions: [ClassSession]
    /// Any date inside the week (or day) being shown.
    let anchor: Date
    let isDayView: Bool

    /// Monday-first, whatever the device's region says.
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }()

    private var calendar: Calendar { Self.calendar }

    var weekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: anchor)?.start ?? calendar.startOfDay(for: anchor)
    }

    func sessions(on day: Date) -> [ClassSession] {
        sessions.filter { calendar.isDate($0.start, inSameDayAs: day) }
    }

    /// The columns: the one chosen day, or Mon–Fri (Mon–Sun when a weekend day has a class).
    var days: [Date] {
        if isDayView { return [calendar.startOfDay(for: anchor)] }
        let week = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let weekendHasClass = week.suffix(2).contains { !sessions(on: $0).isEmpty }
        return weekendHasClass ? week : Array(week.prefix(5))
    }

    /// The hours drawn: 9:00–17:00 at least, stretched to fit any earlier or later class.
    var hours: [Int] {
        let shown = days.flatMap(sessions(on:))
        let first = min(9, shown.map { calendar.component(.hour, from: $0.start) }.min() ?? 9)
        let last = max(17, shown.map(endHour).max() ?? 17)
        return Array(first..<max(last, first + 1))
    }

    /// The hour a class finishes in, rounded up (a 10:30 finish ends the 10:00 row's neighbour at 11).
    func endHour(_ session: ClassSession) -> Int {
        let hour = calendar.component(.hour, from: session.end)
        let minute = calendar.component(.minute, from: session.end)
        return minute > 0 ? hour + 1 : hour
    }

    /// Teaching week: counted from the first class of the semester the shown classes belong to.
    var teachingWeek: Int? {
        guard let course = days.flatMap(sessions(on:)).first?.course else { return nil }
        let semester = sessions.filter { $0.course?.term == course.term && $0.course?.year == course.year }
        guard let earliest = semester.map(\.start).min(),
              let firstWeek = calendar.dateInterval(of: .weekOfYear, for: earliest)?.start else { return nil }
        let weeks = calendar.dateComponents([.weekOfYear], from: firstWeek, to: weekStart).weekOfYear ?? 0
        return weeks >= 0 ? weeks + 1 : nil
    }

    var title: String {
        guard let first = days.first, let last = days.last else { return "" }
        if isDayView {
            return first.formatted(.dateTime.weekday(.wide).day().month(.wide))
        }
        let range: String
        if calendar.isDate(first, equalTo: last, toGranularity: .month) {
            range = "\(first.formatted(.dateTime.day()))–\(last.formatted(.dateTime.day().month(.wide)))"
        } else {
            range = "\(first.formatted(.dateTime.day().month(.abbreviated))) – \(last.formatted(.dateTime.day().month(.abbreviated)))"
        }
        return teachingWeek.map { "Week \($0) · \(range)" } ?? range
    }

    /// The anchor moved one day (day view) or one week (week view) forwards or backwards.
    func shiftedAnchor(by direction: Int) -> Date {
        let component: Calendar.Component = isDayView ? .day : .weekOfYear
        return calendar.date(byAdding: component, value: direction, to: anchor) ?? anchor
    }

    /// Minutes from the top of the grid (the first shown hour) to the class's start.
    func startMinutes(of session: ClassSession) -> Int {
        let firstHour = hours.first ?? 9
        return calendar.component(.hour, from: session.start) * 60
            + calendar.component(.minute, from: session.start) - firstHour * 60
    }

    /// How long the class runs, in hours.
    func durationHours(of session: ClassSession) -> Double {
        session.end.timeIntervalSince(session.start) / 3600
    }

    func isToday(_ day: Date) -> Bool {
        calendar.isDateInToday(day)
    }
}
