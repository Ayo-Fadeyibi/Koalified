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
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(.fredoka(.footnote, .semibold))
                .foregroundStyle(Color.newInk)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .neoBrutalist(backgroundColor: isSelected ? Color.inkMint : Color.surface, cornerRadius: 20, shadowOffset: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CourseFilterChip(title: "Current", isSelected: true) {}
        CourseFilterChip(title: "Past", isSelected: false) {}
    }
    .padding()
}
