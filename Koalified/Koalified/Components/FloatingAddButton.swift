//
//  FloatingAddButton.swift
//  Koalified
//

import SwiftUI

/// The round mint button that floats over the bottom-right of a screen. Shows "+" unless an
/// icon from the asset catalog is given.
struct FloatingAddButton: View {
    /// Asset catalog icon to show instead of "+".
    var image: String? = nil
    /// Spoken by VoiceOver; describe what the button does when it isn't plain "Add".
    var accessibilityLabel: LocalizedStringKey = "Add"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let image {
                    Image(image)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                } else {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                }
            }
            .foregroundStyle(Color.onMint)
            .frame(width: Layout.fabSize, height: Layout.fabSize)
            .neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: Layout.fabSize / 2)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HStack {
        FloatingAddButton {}
        FloatingAddButton(image: "wallet-cards", accessibilityLabel: "Assessment wallet") {}
    }
    .padding()
}
