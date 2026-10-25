//
//  MonthGridView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

struct MonthGridView: View {
    @State private var month: Date = .now

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current
    
    let markers: [CalendarMarker]

    private var markersByDay: [Date: [CalendarMarker]] {
        Dictionary(grouping: markers) { calendar.startOfDay(for: $0.date) }
    }

    // Mon-first weekday letters, in the user's language
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols   // starts on Sunday
        return Array(symbols[1...]) + [symbols[0]]
    }

    private func shift(_ months: Int) {
        month = calendar.date(byAdding: .month, value: months, to: month) ?? month
    }

    var body: some View {
        let days = CalendarMath.days(in: month)

        Card {
            VStack(spacing: 12) {
                // Header: < October 2026 >
                HStack {
                    Button { shift(-1) } label: { Image(systemName: "chevron.left") }
                    Spacer()
                    Text(month.formatted(.dateTime.month(.wide).year()))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Button { shift(1) } label: { Image(systemName: "chevron.right") }
                }
                .foregroundStyle(Color.inkPrimary)

                // Weekday letters
                LazyVGrid(columns: columns) {
                    ForEach(weekdaySymbols.indices, id: \.self) { i in
                        Text(weekdaySymbols[i])
                            .font(.caption)
                            .foregroundStyle(Color.inkSecondary)
                    }
                }

                // The days
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(days.indices, id: \.self) { i in
                        if let date = days[i] {
                            dayCell(date)
                        } else {
                            Color.clear.frame(height: 32)
                        }
                    }
                }
            }
            .padding(14)
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let kinds = Set((markersByDay[calendar.startOfDay(for: date)] ?? []).map(\.kind))

        return Text("\(calendar.component(.day, from: date))")
            .font(.subheadline.weight(isToday ? .bold : .regular))
            .foregroundStyle(isToday ? Color.white : Color.inkPrimary)
            .frame(width: 32, height: 32)
            .background(isToday ? Color.inkPop : Color.clear, in: Circle())
            .overlay(alignment: .bottom) {
                HStack(spacing: 3) {
                    if kinds.contains(.deadline) {
                        Circle().fill(Color.inkPop).frame(width: 5, height: 5)
                    }
                    if kinds.contains(.drop) {
                        Circle().strokeBorder(Color.inkPop, lineWidth: 1).frame(width: 5, height: 5)
                    }
                }
                .offset(y: 8)
            }
    }
}

#Preview {
    let courses = try! PreviewData.container.mainContext.fetch(FetchDescriptor<Course>())
    MonthGridView(markers: CalendarMarker.markers(from: courses)).padding()
}
