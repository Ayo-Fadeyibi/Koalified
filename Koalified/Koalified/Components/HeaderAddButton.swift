//
//  HeaderAddButton.swift
//  Koalified
//

import SwiftUI

/// The "+ Add" button in a screen header. A flat outlined pill, so it reads as an action and doesn't
/// look like a twin of the round, filled profile avatar beside it.
struct HeaderAddButton: View {
    var title: LocalizedStringKey = "Add"
    /// Spoken by VoiceOver; describe what gets added when it isn't obvious from the screen.
    var accessibilityLabel: LocalizedStringKey? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus")
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .overlay(Capsule().strokeBorder(Color.inkBorder, lineWidth: 2))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel.map { Text($0) } ?? Text(title))
    }
}

#Preview {
    HStack {
        HeaderAddButton {}
        ProfileAvatarButton()
    }
    .padding()
    .background(Color.screenBackground)
}
