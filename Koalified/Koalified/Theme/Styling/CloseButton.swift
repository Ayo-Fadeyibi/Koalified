//
//  CloseButton.swift
//  Koalified
//
//  The top-right Skip button used by `.closeButton(...)`.
//

import SwiftUI

/// Adds a "Skip" button to the top-right of the navigation bar that runs `action` (used to leave onboarding).
struct CloseButton: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            TextButton(title: "Skip", color: Color.textSecondary,
                                       font: .fredoka(.footnote, .bold), action: action)
            }
        }
    }
}
