//
//  Card.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
                } .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.cardBorder, lineWidth: 1)
        }
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
