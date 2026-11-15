//
//  CalendarHeader.swift
//  Koalified
//

import SwiftUI

/// Title at the top of the Timetable tab, with the profile avatar on the right.
struct CalendarHeader: View {
    var body: some View {
        HStack {
            Text("Timetable")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            ProfileAvatarButton()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        CalendarHeader()
            .padding()
    }
}
