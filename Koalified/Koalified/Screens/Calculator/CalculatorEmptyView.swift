//
//  CalculatorEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Empty state for the Calculator tab, shown when there is no course to calculate grades for.
struct CalculatorEmptyView: View {

    var body: some View {
        EmptyStateView(
            icon: .asset("calculator"),
            title: "Add a course to start",
            message: "The calculator needs a course with its assessments and weights. Add one and enter any marks you already have.",
            primaryTitle: "Add a course",
            primaryAction: { print("add course") },
            secondaryTitle: "Import timetable",
            secondaryAction: { print("import") }
        )
    }
}

#Preview {
    CalculatorEmptyView()
}
