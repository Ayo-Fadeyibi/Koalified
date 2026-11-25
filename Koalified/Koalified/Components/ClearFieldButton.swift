//
//  ClearFieldButton.swift
//  Koalified
//

import SwiftUI

/// The small ⓧ shown at the end of a text field that has something in it; empties the field.
struct ClearFieldButton: View {
    var label: LocalizedStringKey = "Clear field"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    ClearFieldButton {}
}
