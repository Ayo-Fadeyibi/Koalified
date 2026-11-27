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
    
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        TimelineView(.everyMinute) { context in
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting(at: context.date))
                        .font(.fredoka(.title2, .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text(context.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                        .font(.fredoka(.footnote))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                
                HStack {
                    HeaderAddButton { activeSheet = .addMenu }
                        .sensoryFeedback(.impact(weight: .medium), trigger: activeSheet) { _, newSheet in
                            newSheet == .addMenu
                        }

                    ProfileAvatarButton()
                }
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    @Previewable @State var showCalendar = false
    TodayHeader(activeSheet: .constant(.addMenu))
        .padding()
}
