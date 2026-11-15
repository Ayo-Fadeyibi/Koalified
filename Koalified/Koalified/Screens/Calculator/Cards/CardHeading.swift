//
//  CardHeading.swift
//  Koalified
//

import SwiftUI

/// Small monospaced caption at the top of a Calculator card, e.g. "TARGET GRADE".
struct CardHeading: View {
    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(.caption, design: .monospaced).weight(.semibold))
            .foregroundStyle(Color.accent)
    }
}

/// Thin rule between rows inside a card.
struct CardDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.cardBorder)
            .frame(height: 1)
    }
}
