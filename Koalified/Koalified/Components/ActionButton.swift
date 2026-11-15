//
//  ActionButton.swift
//  Koalified
//

import SwiftUI

/// Compact bordered button that stays on one line and fills its share of a row, like Edit / View / Delete.
struct ActionButton: View {
    let title: LocalizedStringKey
    var color: Color = Color.textPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ActionButton(title: "Edit") {}
        ActionButton(title: "Delete", color: Color.errorText) {}
    }
    .padding()
}
