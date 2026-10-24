//
//  Untitled.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//
import SwiftUI

struct FormField<Content: View>: View {
    let label: String
    let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
                .fontWeight(.bold)

            content
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(Color.cardBorder, lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
