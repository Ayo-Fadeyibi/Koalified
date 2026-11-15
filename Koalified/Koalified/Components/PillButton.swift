//
//  PillButton.swift
//  Koalified
//

import SwiftUI

/// Small pill-shaped button with the hard shadow, for filters and inline actions ("Current", "Add mark").
/// Pass `bgColor` to tint it, for example when it is the selected filter.
struct PillButton: View {
    let title: LocalizedStringKey
    var systemImage: String? = nil
    var color: Color = Color.textPrimary
    var bgColor: Color = Color.cardSurface
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 8
    var shadowOffset: CGFloat = 3
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(.fredoka(.footnote, .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .neoBrutalist(backgroundColor: bgColor, cornerRadius: 20, shadowOffset: shadowOffset)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        PillButton(title: "Current", bgColor: Color.tintMint) {}
        PillButton(title: "Add mark", systemImage: "plus", color: Color.accent) {}
    }
    .padding()
}
