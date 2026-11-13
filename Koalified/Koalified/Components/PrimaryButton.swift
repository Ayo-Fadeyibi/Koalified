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
    /// Corner radius of the button. Pass a large value for a pill shape.
    var cornerRadius: CGFloat = Layout.radiusSmall
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .boxStyling(bgColor: Color.mintFill, cRadius: cornerRadius, sColor: Color.textSecondary, lWidth: 1.5)
        }
    }
}

#Preview {
    PrimaryButton(title: "Continue") { print("tapped") }
}
