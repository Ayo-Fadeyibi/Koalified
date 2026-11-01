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
            .background(Color.canvas)
    }
    
    /// Large bold screen title.
    func primaryTextStyling() -> some View {
        self.foregroundStyle(Color.inkPrimary)
        .font(.fredoka(.largeTitle, .bold))
    }
    
    /// Subheadline text in the secondary ink colour (subtitles, captions).
    func secondaryTextStyling() -> some View {
        self.font(.fredoka(.subheadline))
            .foregroundStyle(Color.inkSecondary)
    }
    
    /// Small secondary text; currently styled the same as `secondaryTextStyling`.
    func tinyText () -> some View {
        self.font(.fredoka(.subheadline))
            .foregroundStyle(Color.inkSecondary)
    }
    
    /// Applies `BoxStyling` with the given background, corner radius, border colour and border width.
    func boxStyling(bgColor: Color, cRadius: CGFloat, sColor: Color, lWidth: CGFloat) -> some View {
        self.modifier(BoxStyling(backgroundColor: bgColor, cornerRadius: cRadius, strokeColor: sColor, lineWidth: lWidth))
    }
    
    /// Adds a top-right "Skip" button that calls `action`.
    func closeButton(action: @escaping () -> Void) -> some View {
        // apply the CloseButton modifier to self
        self.modifier(CloseButton(action: action))
    }
    
}
