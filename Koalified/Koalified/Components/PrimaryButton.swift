//
//  PrimaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// Full-width filled call-to-action button.
struct PrimaryButton: View {
    
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.newInk)
                .frame(maxWidth: .infinity)
                .padding()
                .neoBrutalist(backgroundColor: Color.inkMint, cornerRadius: Layout.radiusSmall)
        }
    }
}

#Preview {
    PrimaryButton(title: "Continue") { print("tapped") }
}
