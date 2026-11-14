//
//  Logic.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import Foundation

//Returns the class sessions that occurs today
func findTodaysSessions (from sessions: [ClassSession]) -> [ClassSession] {
    let calendar = Calendar.current
    var todaySessions = sessions.filter{calendar.isDateInToday($0.start)}
    todaySessions.sort{
        $0.start < $1.start
    }
    
    return todaySessions
}

/// Today's sessions that are in progress or still to come, in start order. Empty when nothing is left.
/// The first element is the next class; the rest follow it.
func findUpcomingSessions (from sessions: [ClassSession], now: Date = .now) -> [ClassSession] {
    // Today's sessions are already sorted by start time
    findTodaysSessions(from: sessions).filter { $0.end > now }
}

/// "9:00 AM - 10:00 AM" for the next session, or empty when there isn't one.
func timeRange (from session: ClassSession?)  -> String {
    guard let start = session?.start, let end = session?.end else { return "" }
    return "\(start.formatted(date: .omitted, time: .shortened)) - \(end.formatted(date: .omitted, time: .shortened))"
}

/// "Now" once the session has started, otherwise "In 20 min" or "In 2h 20m" until it starts.
func countdownLabel(to session: ClassSession?, now: Date = .now) -> String {
    guard let session else { return "" }
    guard session.start > now else { return "Now" }
    let minutes = Int((session.start.timeIntervalSince(now) / 60).rounded(.up))
    guard minutes >= 60 else { return "In \(minutes) min" }
    let (hours, remainder) = minutes.quotientAndRemainder(dividingBy: 60)
    return remainder == 0 ? "In \(hours)h" : "In \(hours)h \(remainder)m"
}
