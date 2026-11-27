//
//  AssessmentEntry.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import WidgetKit

struct AssessmentEntry: TimelineEntry {
    let date: Date
    /// Upcoming assessments at `date`, soonest first.
    let upcoming: [AssessmentSnapshot]

    var next: AssessmentSnapshot? { upcoming.first }
}
