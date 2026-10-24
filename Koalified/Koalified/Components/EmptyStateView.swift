//
//  EmptyStateView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String                 
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let primaryTitle: LocalizedStringKey
    let primaryAction: () -> Void
    var secondaryTitle: LocalizedStringKey? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(Color.accentText)
                .frame(width: 96, height: 96)
                .background(Color.cardBorder.opacity(0.5), in: RoundedRectangle(cornerRadius: Layout.radiusLarge))

            Text(title)
                .font(.title3.weight(.bold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: primaryTitle, action: primaryAction)
            if let secondaryTitle, let secondaryAction {
                SecondaryButton(title: secondaryTitle, action: secondaryAction)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
