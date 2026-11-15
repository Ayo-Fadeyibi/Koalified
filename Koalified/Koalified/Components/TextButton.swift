//
//  TextButton.swift
//  Koalified
//

import SwiftUI

/// Borderless text-only button for light actions like Done, Cancel and Skip.
struct TextButton: View {
    let title: LocalizedStringKey
    var color: Color = Color.accent
    var font: Font = .fredoka(.body, .bold)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(color)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TextButton(title: "Done") {}
}
