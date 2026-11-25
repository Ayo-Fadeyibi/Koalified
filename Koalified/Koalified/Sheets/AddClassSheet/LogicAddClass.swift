//
//  LogicAddClass.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import Foundation

func minutesIntoDay(_ date: Date) -> Int {
    let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
    return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
}

func timesAreValid(from start: Date, to end: Date) -> Bool {
    minutesIntoDay(end) > minutesIntoDay(start)
}

struct SemesterDates {
    let classesStart: Date
    let classesEnd: Date
    let breakStart: Date?
    let breakEnd: Date?
}

func semesterDates(term: Term, year: Int) -> SemesterDates? {
    switch (term, year) {
    case (.S2, 2026):
        guard let start = makeDate(day: 27, month: 7, year: 2026),
              let end = makeDate(day: 30, month: 10, year: 2026) else { return nil }
        return SemesterDates(
            classesStart: start,
            classesEnd: end,
            breakStart: makeDate(day: 28, month: 9, year: 2026),
            breakEnd: makeDate(day: 5, month: 10, year: 2026)
        )
        
    case (.S3, 2026):
        guard let start = makeDate(day: 30, month: 11, year: 2026),
              let end = makeDate(day: 29, month: 1, year: 2027) else { return nil }
        return SemesterDates(
            classesStart: start,
            classesEnd: end,
            breakStart: makeDate(day: 25, month: 12, year: 2026),
            breakEnd: makeDate(day: 3, month: 1, year: 2027)
        )
        
    case (.S1, 2027):
        guard let start = makeDate(day: 22, month: 2, year: 2027),
              let end = makeDate(day: 28, month: 5, year: 2027) else { return nil }
        return SemesterDates(
            classesStart: start,
            classesEnd: end,
            breakStart: makeDate(day: 26, month: 3, year: 2027),
            breakEnd: makeDate(day: 4, month: 4, year: 2027)
            )
        
    case (.S2, 2027): guard let start = makeDate(day: 26, month: 7, year: 2027),
                            let end = makeDate(day: 29, month: 10, year: 2027) else { return nil }
                      return SemesterDates(
                          classesStart: start,
                          classesEnd: end,
                          breakStart: makeDate(day: 27, month: 9, year: 2027),
                          breakEnd: makeDate(day: 4, month: 10, year: 2027)
                          )
        
    case (.S3, 2027):  guard let start = makeDate(day: 29, month: 11, year: 2027),
                             let end = makeDate(day: 28, month: 1, year: 2028) else { return nil }
                       return SemesterDates(
                           classesStart: start,
                           classesEnd: end,
                           breakStart: makeDate(day: 25, month: 12, year: 2027),
                           breakEnd: makeDate(day: 3, month: 1, year: 2028)
                           )
        
    default: return nil
    }
}

func weeklyDates(weekday: Int, in semester: SemesterDates) -> [Date] {
    
    guard (1...7).contains(weekday) else { return [] }
    
    let calendar = Calendar.current
    var current = semester.classesStart

    // Move forward to the first matching weekday
    while calendar.component(.weekday, from: current) != weekday {
        guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { return [] }
        current = next
    }

    // Collect each weekly occurrence, skipping the mid-semester break
    var dates: [Date] = []
    while current <= semester.classesEnd {
        let inBreak: Bool
        if let breakStart = semester.breakStart, let breakEnd = semester.breakEnd {
            inBreak = current >= breakStart && current <= breakEnd
        } else {
            inBreak = false
        }
        if !inBreak { dates.append(current) }

        guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: current) else { break }
        current = next
    }
    return dates
}

func combine(day: Date, time: Date) -> Date? {
    let calendar = Calendar.current
    let d = calendar.dateComponents([.year, .month, .day], from: day)
    let t = calendar.dateComponents([.hour, .minute], from: time)

    guard let year = d.year, let month = d.month, let dayNumber = d.day,
          let hour = t.hour, let minute = t.minute else { return nil }

    return makeDate(day: dayNumber, month: month, year: year, hour: hour, minute: minute)
}

/// The class's start and end on each of `days`, using the hour and minute of `start` and `end`.
func classTimes(on days: [Date], start: Date, end: Date) -> [(start: Date, end: Date)] {
    days.compactMap { day in
        guard let s = combine(day: day, time: start),
              let e = combine(day: day, time: end) else { return nil }
        return (s, e)
    }
}

/// The "These classes overlap" alert text for a class that clashes with `hits`.
func clashMessage(for hits: [ClassSession]) -> String {
    guard let first = hits.first else { return "" }

    let name = first.course?.courseCode ?? "another class"
    let when = first.start.formatted(.dateTime.weekday(.wide).hour().minute())

    if hits.count == 1 {
        return "This overlaps \(name) on \(when). Both classes will be marked as clashing."
    } else {
        return "This overlaps \(hits.count) classes, starting with \(name) on \(when). All of them will be marked as clashing."
    }
}

func overlaps(_ aStart: Date, _ aEnd: Date, _ bStart: Date, _ bEnd: Date) -> Bool{
    return aStart < bEnd && bStart < aEnd
}

func clashes(with existing: [ClassSession],
             newTimes: [(start: Date, end: Date)]) -> [ClassSession]{
    existing.filter { session in
        session.type != .REC && newTimes.contains {
            overlaps(session.start, session.end, $0.start, $0.end)
        }
    }
}

/// The most classes that can run at the same moment; the timetable grid can't lay out more than this.
let maxClashingClasses = 3

/// Whether adding a class at any of these times would make more than `maxClashingClasses` classes overlap.
/// Each time is checked on its own, so a weekly class isn't blocked by adding up clashes from every week.
func exceedsClashLimit(existing: [ClassSession], newTimes: [(start: Date, end: Date)]) -> Bool {
    newTimes.contains { clashes(with: existing, newTimes: [$0]).count >= maxClashingClasses }
}
