//
//  TodayEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct TodayEmptyView: View {

    var body: some View {
        EmptyStateView(
            systemImage: "calendar",
            title: "Add your classes to get started",
            message: "Nothing to show yet. Import your timetable, or add classes by hand.",
            primaryTitle: "Import timetable",
            primaryAction: { print("import timetable") },
            secondaryTitle: "Set up manually",
            secondaryAction: { print("set up manually") }
        )
    }
}

#Preview {
    TodayEmptyView()
}
