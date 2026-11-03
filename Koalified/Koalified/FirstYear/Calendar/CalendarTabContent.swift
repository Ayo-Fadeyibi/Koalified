//
//  CalendarTabContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

/// The Calendar mode of the Today screen: a month grid of deadlines and drop dates
/// above a card listing what is coming up (or what is on the day the user tapped).
struct CalendarTabContent: View {
    @Query private var courses: [Course]
    @State private var selectedDate: Date?

    var body: some View {
        let markers = CalendarMarker.markers(from: courses)

        VStack(spacing: 16) {
            MonthGridView(markers: markers, selectedDate: $selectedDate)
            ScrollView {
                ComingUpCard(markers: markers,
                             selectedDate: selectedDate,
                             onClear: { selectedDate = nil })
            }.scrollIndicators(.hidden)
        }
    }
}

#Preview {
    CalendarTabContent()
        .padding()
        .modelContainer(PreviewData.container)
}
