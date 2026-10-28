//
//  ComingUpCard.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

/// Card under the month grid. If a day is selected it lists that day's markers (with a Clear button),
/// and always lists the next five upcoming markers below.
//Made by claude, Don't understand code yet
struct ComingUpCard: View {
    let markers: [CalendarMarker]
    let selectedDate: Date?
    let onClear: () -> Void

    private let calendar = Calendar.current

    /// Markers that fall on the selected day (empty if no day is selected).
    private var onSelectedDay: [CalendarMarker] {
        guard let selectedDate else { return [] }
        return markers.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    /// The next five markers from today onwards, soonest first.
    private var upcoming: [CalendarMarker] {
        let today = calendar.startOfDay(for: .now)
        return Array(
            markers.filter { $0.date >= today }
                   .sorted { $0.date < $1.date }
                   .prefix(5)
        )
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                if let selectedDate {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedDate, format: .dateTime.weekday(.wide).day().month(.wide))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.inkPrimary)
                            Spacer()
                            Button("Clear", action: onClear)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentText)
                        }
                        rows(onSelectedDay, emptyText: "Nothing on this day")
                    }
                    Divider()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Coming up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.inkPrimary)
                    rows(upcoming, emptyText: "Nothing coming up")
                }
            }
            .padding(14)
        }
    }

    /// A divided list of marker rows, or `emptyText` when there are none.
    @ViewBuilder
    private func rows(_ items: [CalendarMarker], emptyText: LocalizedStringKey) -> some View {
        if items.isEmpty {
            Text(emptyText)
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
        } else {
            ForEach(items) { marker in
                row(marker)
                if marker.id != items.last?.id { Divider() }
            }
        }
    }

    /// One row: a day/month badge, then the marker's title and course code.
    private func row(_ marker: CalendarMarker) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text("\(calendar.component(.day, from: marker.date))")
                    .font(.headline)
                Text(marker.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2)
            }
            .foregroundStyle(Color.inkPrimary)
            .frame(width: 46, height: 48)
            .background(Color.inkPop.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: Layout.radiusSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(marker.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.inkPrimary)
                Text(marker.courseCode)
                    .font(.caption)
                    .foregroundStyle(Color.inkSecondary)
            }
            Spacer()
        }
    }
}
