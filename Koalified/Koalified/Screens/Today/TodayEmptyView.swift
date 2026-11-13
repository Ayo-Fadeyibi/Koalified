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
    /// Called when the user taps "Import timetable".
    let onImport: () -> Void
    /// Called when the user taps "Add a class manually".
    let onAddManually: () -> Void

    var body: some View {
        EmptyStateView(
            header1: "Welcome to your semester",
            title1: "Your day starts here.",
            title2: "Check it before you keep it",
            message1: "Import your timetable to see your next class, deadlines and directions.",
            message2: "You should review the courses, class times and any assessment data found in your import.",
            primaryTitle1: "Import timetable",
            primaryAction1: onImport,
            secondaryTitle: "Add a class manually",
            secondaryAction: onAddManually
        ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    TodayEmptyView(onImport: {}, onAddManually: {})
        .padding(16)
        .background(Color.screenBackground)
}
