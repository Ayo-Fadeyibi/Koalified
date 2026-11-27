//
//  AssessmentLogic.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import Foundation
import SwiftData

/// Every assessment in the shared store, for the widgets' timelines.
func loadAssessmentItems() -> [AssessmentItem] {
    let context = ModelContext(AppStore.container)
    return (try? context.fetch(FetchDescriptor<AssessmentItem>())) ?? []
}

func makeAssessmentSnapshot(from assessment: AssessmentItem) -> AssessmentSnapshot {
    AssessmentSnapshot(courseCode: assessment.course?.courseCode ?? "----", dueDate: assessment.dueDate, title: assessment.title, weight: assessment.weight)
}

func findUpcomingAssessments(from assessments: [AssessmentItem], now: Date = .now) -> [AssessmentItem] {
    assessments.filter{
        $0.dueDate.addingTimeInterval(3600) > now && !$0.isDone
    }.sorted {
        $0.dueDate < $1.dueDate
    }
}
