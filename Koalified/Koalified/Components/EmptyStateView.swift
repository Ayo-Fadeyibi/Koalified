//
//  EmptyStateView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Placeholder shown when a screen has no content: an icon, title and message,
/// a primary button and an optional secondary button.

enum EmptyIcon {
    case system(String)
    case asset(String)

    var image: Image {
        switch self {
        case .system(let name):
            return Image(systemName: name)
        case .asset(let name):
            return Image(name)
        }
    }
}

struct EmptyStateView: View {
    let icon: EmptyIcon
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let primaryTitle: LocalizedStringKey
    let primaryAction: () -> Void
    var secondaryTitle: LocalizedStringKey? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            icon.image
                .resizable()
                .scaledToFit()
                .font(.system(size: 40))
                .foregroundStyle(Color.accentText)
                .frame(width: 96, height: 96)
                

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
