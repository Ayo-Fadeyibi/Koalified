//
//  BoxStyling.swift
//  Koalified
//
//  The padded neo-brutalist box used by `.boxStyling(...)`.
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
