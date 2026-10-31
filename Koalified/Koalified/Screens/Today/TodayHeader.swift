//
//  TodayHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Header of the Today screen: a large "Good morning" title with today's date underneath,
/// and a button on the right that switches between the agenda and the calendar.
struct TodayHeader: View {
    /// True while the calendar is showing instead of the agenda.
    @Binding var showCalendar: Bool

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(.fredoka(.largeTitle, .bold))
                    .foregroundStyle(Color.inkPrimary)
                Text(Date.now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                    .font(.fredoka(.footnote))
                    .foregroundStyle(Color.inkSecondary)
            }
            Spacer()

            Button {
                showCalendar.toggle()
            } label: {
                // Calendar icon opens the calendar; the list icon returns to the agenda.
                Image(systemName: showCalendar ? "list.bullet" : "calendar")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.accentText)
                    .frame(width: 48, height: 48)
                    .neoBrutalist(backgroundColor: Color.surface, cornerRadius: Layout.radiusSmall)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showCalendar ? "Agenda" : "Calendar")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    @Previewable @State var showCalendar = false
    TodayHeader(showCalendar: $showCalendar)
        .padding()
}
