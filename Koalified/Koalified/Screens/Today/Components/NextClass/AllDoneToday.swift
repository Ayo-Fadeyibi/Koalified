//
//  AllDoneToday.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 17/11/2026.
//

import SwiftUI

struct AllDoneToday: View {
    var body: some View {
        EmptyStateView(header1: "All done for today", title1: "Class wrapped. Get some rest", message1: "You’re clear for the rest of the evening.", primaryTitle1: "See tomorrow’s classes", primaryAction1: {})
    }
}

#Preview {
    AllDoneToday()
}
