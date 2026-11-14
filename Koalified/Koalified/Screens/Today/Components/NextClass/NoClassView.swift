//
//  NoClassView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

struct NoClassView: View {
    
    /// Called when the user taps "Import timetable".
    let onImport: () -> Void
    /// Called when the user taps "Add a class manually".
    let onAddManually: () -> Void

    
    var body: some View {
        EmptyStateView(
            header1: "A LITTLE BREATHING ROOM",
            header2: "CSSE1001 · Individual",
            title1: "No classes today.",
            title2: "Quiz 1",
            message1: "A free day for a study session, catching up or taking a break.",
            message2: "3 days left · 15% of course grade",
            primaryTitle1: "See your week",
            primaryAction1: {},
            secondaryTitle2: "View Assessment",
            secondaryAction2: {}
            
            
        ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    NoClassView(onImport: {}, onAddManually: {})
}
