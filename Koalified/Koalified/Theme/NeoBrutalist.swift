//
//  NeoBrutalist.swift
//  Koalified
//
//  The app's visual style: flat fills, thick dark borders and a solid (unblurred) offset shadow.
//

import SwiftUI

/// Draws a flat rounded box with a thick border and a hard shadow offset to the bottom-right.
/// Border and shadow default to `Color.textPrimary`, which flips to white in dark mode so they stay visible.
struct NeoBrutalistCard: ViewModifier {
    var backgroundColor: Color = Color.cardSurface
    var cornerRadius: CGFloat = Layout.radiusCard
    var borderWidth: CGFloat = Layout.borderWidth
    var shadowOffset: CGFloat = Layout.shadowOffset
    var borderColor: Color = Color.textPrimary
    var shadowColor: Color = Color.textPrimary

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            // Solid, unblurred shadow offset to bottom-right
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(shadowColor)
                    .offset(x: shadowOffset, y: shadowOffset)
            )
            // Reserve room for the shadow in the layout. Without this the shadow is drawn outside the
            // view's frame, so a ScrollView (or the screen edge) clips it.
            .padding(.trailing, shadowOffset)
            .padding(.bottom, shadowOffset)
    }
}

extension View {
    /// Applies the neo-brutalist box style (see `NeoBrutalistCard`). Does not add padding.
    func neoBrutalist(
        backgroundColor: Color = Color.cardSurface,
        cornerRadius: CGFloat = Layout.radiusCard,
        borderWidth: CGFloat = Layout.borderWidth,
        shadowOffset: CGFloat = Layout.shadowOffset,
        borderColor: Color = Color.textPrimary,
        shadowColor: Color = Color.textPrimary
    ) -> some View {
        self.modifier(
            NeoBrutalistCard(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                borderWidth: borderWidth,
                shadowOffset: shadowOffset,
                borderColor: borderColor,
                shadowColor: shadowColor
            )
        )
    }
}
