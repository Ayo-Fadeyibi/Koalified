//
//  ViewStyling.swift
//  Koalified
//
//  Shortcuts on `View` for screen containers, text styles and the modifiers in this folder.
//

import SwiftUI

/// Convenience styling helpers used across screens.
extension View {

    /// Standard screen container: horizontal padding, fills the screen, canvas background.
    func mainContainerStyling() -> some View {
        self.padding(.horizontal, Layout.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.screenBackground)
    }
    
    func containerStyling() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.screenBackground)
    }
    
    /// Large bold screen title.
    func primaryTextStyling() -> some View {
        self.foregroundStyle(Color.textPrimary)
        .font(.fredoka(.largeTitle, .bold))
    }
    
    /// Subheadline text in the secondary ink colour (subtitles, captions).
    func secondaryTextStyling() -> some View {
        self.font(.fredoka(.subheadline))
            .foregroundStyle(Color.textSecondary)
    }
    
    func boldSecondaryTextStyling() -> some View{
        self.font(.fredoka(.subheadline, .bold))
            .foregroundStyle(Color.textSecondary)
    }
    
    func plainStyling() -> some View{
        self.background(Color.cardSurface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusSmall)
                    .strokeBorder(Color.inkBorder, lineWidth: 2)
            )
    }
    
    /// Text input box: padded card surface with a faint border that thickens and gains an offset ink
    /// shadow while `isFocused` is true.
    func textFieldStyling(isFocused: Bool) -> some View {
        self.padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isFocused ? Color.inkBorder : Color.inkBorder.opacity(0.45),
                        lineWidth: isFocused ? 2.5 : 1.5
                    )
            )
            .background {
                if isFocused {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.inkBorder)
                        .offset(x: 3, y: 3)
                }
            }
            .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    /// Small secondary text; currently styled the same as `secondaryTextStyling`.
    func tinyText () -> some View {
        self.font(.fredoka(.subheadline))
            .foregroundStyle(Color.textSecondary)
    }
    
    /// Applies `BoxStyling` with the given background, corner radius, border colour and border width.
    func boxStyling(bgColor: Color, cRadius: CGFloat, sColor: Color, lWidth: CGFloat) -> some View {
        self.modifier(BoxStyling(backgroundColor: bgColor, cornerRadius: cRadius, strokeColor: sColor, lineWidth: lWidth))
    }
    
    /// Gives a presented sheet the screen background and a thick border so its edge stays visible against the
    /// screen behind it, which is hard to see in dark mode. Apply it to the sheet's content where it is presented.
    /// The border is part of the sheet's own background, so it follows the sheet's exact outline; the sheet's
    /// content must therefore not paint an opaque background of its own, or it would cover the border.
    /// `topInset` moves the border's top edge down. Short, floating sheets (a fixed-height detent) are drawn
    /// a couple of points above their visible top, which clipped the border, so they pass about 2.5.
    /// Full-height sheets need none.
    func sheetBorder(cornerRadius: CGFloat = 32, lineWidth: CGFloat = 3, topInset: CGFloat = 0) -> some View {
        self.presentationCornerRadius(cornerRadius)
            .presentationBackground {
                ZStack {
                    Color.screenBackground
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.inkBorder, lineWidth: lineWidth)
                        .padding(.top, topInset)
                }
            }
    }

    /// Adds a top-right "Skip" button that calls `action`.
    func closeButton(action: @escaping () -> Void) -> some View {
        // apply the CloseButton modifier to self
        self.modifier(CloseButton(action: action))
    }
    
}
