//
//  MilestoneAccessibility.swift
//  Koalified
//

import Foundation

/// The sentence VoiceOver speaks for a milestone tile, e.g. "Census Date, 12 days away".
/// Built from the milestone's own data and written in normal words (not the capitalised on-screen text).
func spokenLabel(for milestone: Milestone, now: Date = .now) -> String {
    let days = daysUntil(milestone.date, from: now)

    switch days {
    case 0:
        return "\(milestone.title), today"
    case 1:
        return "\(milestone.title), 1 day away"
    default:
        return "\(milestone.title), \(days) days away"
    }
}
