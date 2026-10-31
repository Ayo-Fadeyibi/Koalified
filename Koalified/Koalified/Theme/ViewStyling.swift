//
//  ViewStyling.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 28/10/2026.
//

import SwiftUI

/// Wraps content in a padded neo-brutalist box (thick border, hard shadow).
/// `strokeColor` and `lineWidth` are kept so existing call sites compile, but the border is now always the
/// ink colour; show a selected state by changing `backgroundColor` instead.
struct BoxStyling: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let strokeColor: Color
    let lineWidth: CGFloat

    func body (content: Content) -> some View {
        content
            .padding(Layout.screenPadding)
            .neoBrutalist(backgroundColor: backgroundColor, cornerRadius: cornerRadius)
    }
}

/// Adds an "X" button to the top-right of the navigation bar that runs `action` (used to dismiss sheets).
struct CloseButton: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                action()
                            } label: {
                                Text("Skip")
                                    .font(.fredoka(.footnote, .bold))
                                    .foregroundStyle(Color.inkSecondary)
                }
            }
        }
    }
}

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
    
    /// Adds a top-right close ("X") button that calls `action`.
    func closeButton(action: @escaping () -> Void) -> some View {
        // apply the CloseButton modifier to self
        self.modifier(CloseButton(action: action))
    }
    
}
