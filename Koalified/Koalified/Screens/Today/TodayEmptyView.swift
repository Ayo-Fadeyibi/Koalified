//
//  TodayEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/*
 This view displays the default content when there's no data stored in the local storage on courses, prompting the user to import or set their courses manually
 */
struct TodayEmptyView: View {

    var body: some View {
        EmptyStateView(
            icon: .system("calendar"),
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
