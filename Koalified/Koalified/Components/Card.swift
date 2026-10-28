//
//  Card.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// Reusable rounded container with a surface background and border; wraps any content in a vertical stack.
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }.boxStyling(bgColor: Color.surface, cRadius: Layout.radiusCard, sColor: Color.cardBorder, lWidth: 1)
    }
}

#Preview {
    ZStack {
        Color.canvas.ignoresSafeArea()
        Card {
            VStack(alignment: .leading, spacing: 4) {
                Text("CSSE1001").font(.headline)
                Text("Running mark 66.7%").foregroundStyle(Color.inkSecondary)
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
