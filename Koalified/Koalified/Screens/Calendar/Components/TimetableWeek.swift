//
//  TimetableWeek.swift
//  Koalified
//

import Foundation
import SwiftData

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

    // MARK: - Clashes

    /// The day's classes grouped into clusters of overlapping classes, each class given a lane.
    func clusters(on day: Date) -> [SessionCluster] {
        let daySessions = sessions(on: day)
        let placements = Self.lanes(for: daySessions.map { DateInterval(start: $0.start, end: max($0.start, $0.end)) })
        let byCluster = Dictionary(grouping: zip(daySessions, placements), by: { $0.1.cluster })

        return byCluster.keys.sorted().compactMap { key in
            guard let members = byCluster[key] else { return nil }
            let lanes = members.map { SessionCluster.Lane(session: $0.0, lane: $0.1.lane) }
                .sorted { $0.session.start < $1.session.start }
            return SessionCluster(lanes: lanes, laneCount: members[0].1.laneCount)
        }
    }

    /// Where one interval sits among the ones it overlaps.
    struct LanePlacement: Equatable {
        /// Index of its cluster: a run of intervals linked by overlaps.
        let cluster: Int
        /// Its lane (0, 1, 2…) inside the cluster; intervals in the same lane never overlap.
        let lane: Int
        /// How many lanes its cluster needs.
        let laneCount: Int
    }

    /// Splits intervals into clusters of overlapping ones and gives each the first free lane in its cluster.
    /// Results are in the same order as `intervals`. Back-to-back intervals (one ends as the next starts) don't clash.
    static func lanes(for intervals: [DateInterval]) -> [LanePlacement] {
        // Earliest first; when two start together the longer one goes first so it takes the leftmost lane.
        let order = intervals.indices.sorted {
            intervals[$0].start != intervals[$1].start
                ? intervals[$0].start < intervals[$1].start
                : intervals[$0].end > intervals[$1].end
        }

        var result = [LanePlacement?](repeating: nil, count: intervals.count)
        var cluster = 0
        var clusterMembers: [(index: Int, lane: Int)] = []
        var clusterEnd = Date.distantPast
        var laneEnds: [Date] = []   // when each lane in the current cluster frees up

        func closeCluster() {
            for member in clusterMembers {
                result[member.index] = LanePlacement(cluster: cluster, lane: member.lane, laneCount: laneEnds.count)
            }
            cluster += 1
            clusterMembers = []
            laneEnds = []
        }

        for index in order {
            let interval = intervals[index]
            // Nothing still running overlaps this one, so it starts a new cluster.
            if !clusterMembers.isEmpty && interval.start >= clusterEnd { closeCluster() }

            let lane = laneEnds.firstIndex { $0 <= interval.start } ?? laneEnds.count
            if lane == laneEnds.count { laneEnds.append(interval.end) } else { laneEnds[lane] = interval.end }
            clusterMembers.append((index, lane))
            clusterEnd = max(clusterEnd, interval.end)
        }
        if !clusterMembers.isEmpty { closeCluster() }

        return result.compactMap { $0 }
    }
}

/// Classes on one day that overlap each other (or a single class with no clash).
struct SessionCluster: Identifiable {
    struct Lane {
        let session: ClassSession
        let lane: Int
    }

    /// The classes in start order, each with its lane.
    let lanes: [Lane]
    let laneCount: Int

    var id: [ClassSession.ID] { lanes.map(\.session.id) }
    var sessions: [ClassSession] { lanes.map(\.session) }
    var isClash: Bool { lanes.count > 1 }
    var start: Date { lanes.map(\.session.start).min() ?? .now }
    var end: Date { lanes.map(\.session.end).max() ?? .now }
}
