//
//  StatusTag.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// Small rounded label such as "Current" or "Past".
struct StatusTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.fredoka(.caption2, .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    HStack {
        StatusTag(text: "Current", color: Color.inkPop)
        StatusTag(text: "Past", color: Color.inkSecondary)
    }
    .padding()
}
