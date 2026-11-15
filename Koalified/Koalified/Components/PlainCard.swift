//
//  PlainCard.swift
//  Koalified
//

import SwiftUI

/// Like `Card` but flat: a rounded surface with the ink border and no offset shadow.
/// Use it for quieter containers (lists, settings) where `Card`'s hard shadow would be too loud.
struct PlainCard<Content: View>: View {
    let bgColor: Color
    let content: Content

    init(bgColor: Color = Color.cardSurface, @ViewBuilder content: () -> Content) {
        self.bgColor = bgColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(Layout.screenPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: Layout.radiusCard).fill(bgColor))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusCard)
                .strokeBorder(Color.inkBorder, lineWidth: Layout.borderWidth)
        )
    }
}

#Preview {
    ZStack {
        Color.screenBackground.ignoresSafeArea()
        PlainCard {
            Text("CSSE1001").font(.fredoka(.headline))
            Text("No shadow on this one").foregroundStyle(Color.textSecondary)
        }
        .padding(16)
    }
}
