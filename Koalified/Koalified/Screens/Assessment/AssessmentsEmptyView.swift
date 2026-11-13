//
//  AssessmentsEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

/// Empty state for a course with no assessments yet.
struct AssessmentsEmptyView: View {
    /// Called when the user taps "Add an assessment".
    let onAdd: () -> Void

    var body: some View {
        EmptyStateView(
            title1: "No assessments yet",
            message1: "Add your assignments, quizzes and exams to track your marks and see what you need.",
            primaryTitle1: "Add an assessment",
            primaryAction1: onAdd
        )
    }
}

#Preview {
    AssessmentsEmptyView(onAdd: {})
}
