//
//  CalendarView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftData
import SwiftUI

struct CalendarView: View {
    
    @Query var sessions: [ClassSession]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            if sessions.isEmpty {
                CalendarEmptyView(onImport: {}, onAddManually: {})
            } else {
                CalendarTabContent()
            }
            
        }
        
       
    }
}


#Preview("With sessions") {
    CalendarView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    CalendarView().modelContainer(EmptyPreviewData.container)
}
