//
//  AssessmentProvider.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import WidgetKit
import SwiftData


struct AssessmentProvider: TimelineProvider{
    
    let sampleEntry: AssessmentEntry = AssessmentEntry(date: .now, upcoming: [
        AssessmentSnapshot(courseCode: "COMP3400", dueDate: .now.addingTimeInterval(86400 * 3), title: "Assignment 1", weight: 15),
        AssessmentSnapshot(courseCode: "MATH1051", dueDate: .now.addingTimeInterval(86400 * 5), title: "Quiz 2", weight: 5),
        AssessmentSnapshot(courseCode: "DECO1800", dueDate: .now.addingTimeInterval(86400 * 9), title: "Design Report", weight: 30)
    ])
    
    func placeholder(in context: Context) -> AssessmentEntry {
        return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AssessmentEntry) -> Void) {
        completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AssessmentEntry>) -> Void) {
        let assessments = loadAssessmentItems()
        let now = Date.now

        
        let upcoming = findUpcomingAssessments(from: assessments, now: now)

        
        var moments: [Date] = [now]
        for assessment in upcoming {
            // Flip to "due now" at the due date, then drop it an hour later
            if assessment.dueDate > now { moments.append(assessment.dueDate) }
            let dropOff = assessment.dueDate.addingTimeInterval(3600)
            if dropOff > now { moments.append(dropOff) }
        }
        moments = Array(Set(moments)).sorted()

        // Step 3: one entry for each moment; `upcoming` is empty once nothing is left
        let entries = moments.map { moment in
            AssessmentEntry(date: moment, upcoming: findUpcomingAssessments(from: assessments, now: moment).map(makeAssessmentSnapshot))
        }

        // Step 4: when to ask for a fresh timeline
        let refreshDate: Date
        if let last = moments.last, last > now {
            refreshDate = last
        } else {
            // Nothing left today: refresh after midnight
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: now)
            refreshDate = calendar.date(byAdding: .day, value: 1, to: today) ?? now.addingTimeInterval(3600)
        }

        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}
