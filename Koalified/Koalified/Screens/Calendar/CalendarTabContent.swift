//
//  CalendarTabContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

/// The Timetable tab: a fixed header above a scrolling weekly grid of classes (or a single day) and an add-class button.
struct CalendarTabContent: View {
    var body: some View {
        NavigationStack {
            // The header and week controls stay put; only the timetable and button below them scroll.
            VStack(alignment: .leading, spacing: 16) {
                CalendarHeader()
                    .padding(.bottom, 10)

                // Week controls are fixed; the grid and the button scroll beneath them.
                WeekGridView {
                    PrimaryButton(title: "Add a class") {}
                }
            }
            .padding([.horizontal, .top], Layout.screenPadding)
            // Let the scrolling content run behind the tab bar instead of stopping above it.
            .ignoresSafeArea(edges: .bottom)
            .background(Color.screenBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    CalendarTabContent()
        .modelContainer(PreviewData.container)
}
