//
//  MileStone.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 18/11/2026.
//

import Foundation

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let note: String
    static let all: [Milestone] = [
        Milestone(title: "Census Date", date: makeDate(day: 31, month: 3, year: 2027) ?? .now, note: "Last day to drop a course without academic or financial penalty."),
        Milestone(title: "Mid Sem Break", date: makeDate(day: 26, month: 3, year: 2027) ?? .now, note: "No scheduled classes for a week, a good chance to catch up on lectures and assignments."),
        Milestone(title: "Swotvac", date: makeDate(day: 31, month: 5, year: 2027) ?? .now, note: "Classes wrap up and study week begins before the central exam period."),
        Milestone(title: "Classes Start", date: makeDate(day: 22, month: 2, year: 2027) ?? .now, note: "Week 1 begins. Lectures, tutorials, and practicals start running on your timetable."),
        Milestone(title: "O-Week", date: makeDate(day: 15, month: 2, year: 2027) ?? .now, note: "Campus welcome events, faculty inductions, and club stalls kick off before classes begin.")
    ]
}
