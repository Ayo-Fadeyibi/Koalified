//
//  TodayContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/*
 This view handles and display the data stored on the local storage including lecture time, location and courses. Shows either the agenda or, when `showCalendar` is true, the calendar view
 */
struct TodayContentView: View {
    /// True to show the calendar instead of the agenda (toggled by the button in `TodayHeader`).
    let showCalendar: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !showCalendar {
                NextClassCard()
                
                HStack (spacing: 5) {
                    Text("Today")
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Tue 20 Oct")
                        .foregroundStyle(Color.textSecondary)
                }.padding(.top, 20)
                
                ForEach(SampleData.classEvents) { data in
                    TodayClassRow(event: data)
                }
            } else {
               CalendarTabContent()
            }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    TodayContentView(showCalendar: false)
}
