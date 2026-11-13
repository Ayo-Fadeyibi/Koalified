//
//  Untitled.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//
import SwiftUI

/// A labelled form row: a bold caption above a bordered input (text field, picker, etc.) passed as content.
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
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(Color.textSecondary)

            content
                .font(.fredoka(.subheadline, .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall, shadowOffset: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
