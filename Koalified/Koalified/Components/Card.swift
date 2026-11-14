//
//  Card.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// Reusable rounded container with a surface background and border; wraps any content in a vertical stack.
/// The background defaults to `cardSurface`; pass `bgColor` to tint a card.
struct Card<Content: View>: View {
    let bgColor: Color
    let content: Content
    
    init(bgColor: Color = Color.cardSurface, @ViewBuilder content: () -> Content) {
        self.bgColor = bgColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }.boxStyling(bgColor: bgColor, cRadius: Layout.radiusCard, sColor: Color.cardBorder, lWidth: 1)
    }
}

#Preview {
    ZStack {
        Color.screenBackground.ignoresSafeArea()
        Card {
            VStack(alignment: .leading, spacing: 4) {
                Text("CSSE1001").font(.fredoka(.headline))
                Text("Running mark 66.7%").foregroundStyle(Color.textSecondary)
            }
            HStack {
                Text("Assignment")
                Text("Due Today")
            }
            PrimaryButton(title: "Lock In"){}
        }
        .padding(16)
    }
}
