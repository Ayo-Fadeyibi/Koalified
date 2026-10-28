//
//  TodayHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

//This view displays the greeting ("Good Morning", "Good Afternoon", "Good Evening") and date
struct TodayHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good morning,")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            Text("Today")
                .font(.largeTitle.weight(.bold))
            Text(Date.now, format: .dateTime.weekday().day().month().year())
                .font(.footnote)
                .foregroundStyle(Color.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    TodayHeader()
}
