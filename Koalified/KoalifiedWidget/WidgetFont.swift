//
//  WidgetFont.swift
//  KoalifiedWidget
//

import SwiftUI

/// Fredoka at a fixed size, shared by every widget.
/// Fredoka ships as one file per weight, so pick the PostScript name rather than the family.
func fredoka(_ size: CGFloat, _ weight: Font.Weight) -> Font {
    let name: String
    switch weight {
    case .bold, .heavy, .black: name = "Fredoka-Bold"
    case .semibold:             name = "Fredoka-SemiBold"
    case .medium:               name = "Fredoka-Medium"
    default:                    name = "Fredoka-Regular"
    }
    return .custom(name, fixedSize: size)
}
