//
//  CourseFilterChip.swift
//  Koalified
//

import SwiftUI

/// A pill-shaped filter button (Current, Past, All); filled mint when it is the selected filter.
struct CourseFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        PillButton(title: LocalizedStringKey(title),
                   bgColor: isSelected ? Color.tintMint : Color.cardSurface,
                   action: action)
    }
}

#Preview {
    HStack {
        CourseFilterChip(title: "Current", isSelected: true) {}
        CourseFilterChip(title: "Past", isSelected: false) {}
    }
    .padding()
}
