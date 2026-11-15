//
//  ProfileEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct ProfileEmptyView: View {
    var body: some View {
        EmptyStateView(
            header1: "MAKE IT YOUR SEMESTER",
            title1: "Ready when you are.",
            title2: "Preferences",
            message1: "Import your timetable to personalise your course list and semester progress.",
            primaryTitle1: "Import timetable",
            primaryAction1: {},
            secondaryTitle2: "Language",
            secondaryAction2: {}
            
        ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


#Preview {
    ProfileEmptyView()
}
