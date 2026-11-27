//
//  CalendarHeader.swift
//  Koalified
//

import SwiftUI

struct CalendarHeader: View {
    
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        HStack {
            Text("Timetable")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            HeaderAddButton { activeSheet = .addMenu }
                .sensoryFeedback(.impact(weight: .medium), trigger: activeSheet) { _, newSheet in
                    newSheet == .addMenu
                }
            ProfileAvatarButton()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        CalendarHeader(activeSheet: .constant(.addMenu))
            .padding()
    }
}
