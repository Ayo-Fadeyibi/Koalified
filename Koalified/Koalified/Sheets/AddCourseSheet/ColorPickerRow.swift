//
//  ColorPickerRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

struct ColorPickerRow: View {
    @Binding var selection: CourseColor?
    let fallback: CourseColor          

    private var current: CourseColor { selection ?? fallback }

    var body: some View {
        FormField("Colour") {
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
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.rawValue.capitalized)
                }
                Spacer()
            }
        }
    }
}
