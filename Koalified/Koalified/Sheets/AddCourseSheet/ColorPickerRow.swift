//
//  ColorPickerRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

/// A row of colour swatches for choosing a course colour. A tick marks the current choice;
/// when nothing has been picked (`selection` is nil) the `fallback` colour is ticked.
struct ColorPickerRow: View {
    @Binding var selection: CourseColor?
    let fallback: CourseColor

    /// The colour to show as selected.
    private var current: CourseColor { selection ?? fallback }

    var body: some View {
        FormField("Colour") {
            // All eleven swatches are wider than a phone screen, so the row scrolls sideways.
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 14) {
                        ForEach(CourseColor.allCases, id: \.self) { option in
                            Button { selection = option } label: {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if option == current {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(option.onColor)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.rawValue.capitalized)
                            .id(option)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                // When editing a course whose colour is off-screen, bring its swatch into view.
                .onAppear { proxy.scrollTo(current) }
            }
        }
    }
}
