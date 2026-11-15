//
//  CalculatorEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Empty state for the Calculator tab, shown when there is no course to calculate grades for.
struct CalculatorEmptyView: View {
    /// Called when the user taps "Add a course".
    let onAddCourse: () -> Void
    /// Called when the user taps "Import timetable".
    let onImport: () -> Void

    var body: some View {
        EmptyStateView(
            title1: "Add a course to start",
            message1: "The calculator needs a course with its assessments and weights. Add one and enter any marks you already have.",
            primaryTitle1: "Add a course",
            primaryAction1: onAddCourse,
            secondaryTitle: "Import timetable",
            secondaryAction: onImport
        ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    CalculatorEmptyView(onAddCourse: {}, onImport: {})
}
