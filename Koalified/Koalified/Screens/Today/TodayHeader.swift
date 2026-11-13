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

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(.fredoka(.largeTitle, .bold))
                    .foregroundStyle(Color.textPrimary)
                Text(Date.now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
                    .font(.fredoka(.footnote))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()

            NavigationLink {
                        ProfileView()
                    } label: {
                Image("user")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.mintFill, in: Circle())
                    .overlay(Circle().strokeBorder(Color.textPrimary, lineWidth: 2))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    @Previewable @State var showCalendar = false
    TodayHeader()
        .padding()
}
