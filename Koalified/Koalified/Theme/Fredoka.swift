//
//  Fredoka.swift
//  Koalified
//
//  The app's typeface. The four weights are bundled in Resources/Font and registered in Info.plist (UIAppFonts).
//

import SwiftUI
import UIKit

/// The Fredoka weights bundled with the app. Fredoka ships as separate font files rather than one
/// variable font, so each weight maps to its own PostScript name.
enum FredokaWeight {
    case regular, medium, semibold, bold

    /// PostScript name of the font file for this weight.
    var fontName: String {
        switch self {
        case .regular:  "Fredoka-Regular"
        case .medium:   "Fredoka-Medium"
        case .semibold: "Fredoka-SemiBold"
        case .bold:     "Fredoka-Bold"
        }
    }
}

extension Font {
    /// Fredoka at the size of a system text style. Scales with Dynamic Type like the system style does.
    /// If no weight is given, `.headline` is semibold (matching the system) and everything else is regular.
    static func fredoka(_ style: Font.TextStyle, _ weight: FredokaWeight? = nil) -> Font {
        let resolved = weight ?? (style == .headline ? .semibold : .regular)
        return .custom(resolved.fontName, size: Fredoka.baseSize(for: style), relativeTo: style)
    }

    /// Fredoka at a fixed point size (does not scale with Dynamic Type). Use for widget mock-ups.
    static func fredoka(size: CGFloat, _ weight: FredokaWeight = .regular) -> Font {
        .custom(weight.fontName, fixedSize: size)
    }
}

enum Fredoka {
    /// Default (Large) point size of each system text style, so Fredoka text matches the old layout.
    static func baseSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:  34
        case .title:       28
        case .title2:      22
        case .title3:      20
        case .headline:    17
        case .body:        17
        case .callout:     16
        case .subheadline: 15
        case .footnote:    13
        case .caption:     12
        case .caption2:    11
        default:           17
        }
    }

    /// Makes UIKit-backed controls (tab bar labels, segmented pickers, navigation bar titles) use Fredoka.
    /// Call once at launch.
    static func applyAppearance() {
        func font(_ weight: FredokaWeight, _ size: CGFloat) -> UIFont {
            UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
        }

        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: font(.medium, 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [.font: font(.semibold, 10)], for: .selected)

        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: font(.medium, 13)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: font(.semibold, 13)], for: .selected)

        UINavigationBar.appearance().titleTextAttributes = [.font: font(.semibold, 17)]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: font(.bold, 34)]
    }
}
