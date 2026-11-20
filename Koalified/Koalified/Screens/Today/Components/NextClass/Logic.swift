//
//  Logic.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import Foundation

//Returns the class sessions that occurs today
func findTodaysSessions (from sessions: [ClassSession], now: Date = .now) -> [ClassSession] {
    let calendar = Calendar.current
    var todaySessions = sessions.filter{calendar.isDate($0.start, inSameDayAs: now)}
    todaySessions.sort{
        $0.start < $1.start
    }
    
    return todaySessions
}

/// Today's sessions that are in progress or still to come, in start order. Empty when nothing is left.
/// The first element is the next class; the rest follow it.
func findUpcomingSessions (from sessions: [ClassSession], now: Date = .now) -> [ClassSession] {
    // Today's sessions are already sorted by start time
    findTodaysSessions(from: sessions, now: now).filter { $0.end > now }
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

func mapsWalkingURL(to destination: String) -> URL? {
    let cleaned = destination.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !cleaned.isEmpty else { return nil }

    let knownSuffixes = ["building", "library", "tower", "centre", "center", "lab", "laboratory", "hall", "theatre", "modwest"]
    let lower = cleaned.lowercased()
    let lastString = lower.split(separator: " ").last
    let hasSuffix = knownSuffixes.contains { lastString?.contains($0) ?? false }

    let queryName = hasSuffix ? cleaned : "\(cleaned) Building"

    var components = URLComponents()
    components.scheme = "https"
    components.host = "maps.apple.com"
    components.path = "/"
    components.queryItems = [
        URLQueryItem(name: "daddr", value: "\(queryName)"),
        URLQueryItem(name: "dirflg", value: "w")
    ]

    return components.url
}

func greeting (at now: Date = .now) -> String {
    let hour = Calendar.current.component(.hour, from: now)
    
    switch hour{
    case 5..<12:
        return "Good morning"
        
    case 12..<17:
        return "Good afternoon"
        
    case 17..<22:
        return "Good evening"
        
    default:
        return "Still up?"
    }
    
}

func daysUntil(_ date: Date, from now: Date = .now) -> Int {
    let calendar = Calendar.current
    return calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)).day ?? 0
}

func makeDate(day: Int, month: Int,
              year: Int = Calendar.current.component(.year, from: .now),
              hour: Int = 0, minute: Int = 0) -> Date? {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    return Calendar.current.date(from: components)
}

func upcomingMilestones(from: [Milestone], now: Date = .now) -> [Milestone] {
    var mileStones = from
    mileStones.sort {
        $0.date < $1.date
    }
    
    let upcoming = mileStones.filter {
        daysUntil($0.date, from: now) >= 0
    }
    
    return upcoming
}

func nextMileStone(from list: [Milestone], now date: Date = .now) -> [Milestone] {
    let upcoming = upcomingMilestones(from: list, now: date)
    return Array(upcoming.prefix(3))
}

func daysLabel(_ days: Int) -> String {
    switch days{
    case 0:
        return "TODAY"
    case 1:
        return "1 DAY"
        
    default:
        return "\(days) DAYS"
    }
}

func nextAssessment(from assessments: [AssessmentItem], now: Date = .now) -> AssessmentItem?{
    var assignments = assessments
    
    assignments.sort {
        $0.dueDate < $1.dueDate
    }
    
    let assignment = assignments.filter {
        $0.mark == nil && $0.dueDate >= now
    }
    
    return assignment.first
    
}

func dueLabel(for date: Date, now: Date = .now) -> String{
    let daysLeft = daysUntil(date, from: now)
    
    switch daysLeft{
    case 0:
        return "Due today"
    case 1:
        return "1 day left"
    default:
        return "\(daysLeft) days left"
    }
}
