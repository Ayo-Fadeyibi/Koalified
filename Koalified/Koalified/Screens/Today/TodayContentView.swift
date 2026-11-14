//
//  TodayContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI
import SwiftData

/*
 This view handles and display the data stored on the local storage including lecture time, location and courses. Shows either the agenda or, when `showCalendar` is true, the calendar view
 */
struct TodayContentView: View {
    
    @Query var sessions: [ClassSession]
    
    private var todaySessions: [ClassSession] {
        findTodaysSessions(from: sessions)
    }
     
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ImportantDates()

            if todaySessions.isEmpty {
                NoClassView(onImport: {}, onAddManually: {})
            } else {
                NextClassView(sessions: sessions)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
    }
}

#Preview {
    TodayContentView()
}
