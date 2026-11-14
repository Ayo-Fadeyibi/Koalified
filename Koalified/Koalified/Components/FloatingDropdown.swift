//
//  FloatingDropdown.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

struct FloatingDropdown<SelectionValue: Hashable>: View {
    let options: [SelectionValue]
    @Binding var selection: SelectionValue
    let optionLabel: (SelectionValue) -> String

    @State private var isExpanded = false
    @State private var triggerHeight: CGFloat = 0

    var body: some View {
        // 1. Trigger Button
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(optionLabel(selection))
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding()
            .background(Color.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                    .stroke(Color.inkBorder, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        // Measure exact button height so the menu always aligns cleanly below it
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            triggerHeight = newHeight
        }
        // 2. Floating Menu Overlay (does not affect layout height)
        .overlay(alignment: .top) {
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                selection = option
                                isExpanded = false
                            }
                        } label: {
                            HStack {
                                Text(optionLabel(option))
                                    .font(.fredoka(.subheadline, selection == option ? .bold : .regular))
                                    .foregroundStyle(Color.textPrimary)

                                Spacer()

                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.greenDeep)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                            .background(
                                selection == option ? Color.mintFill.opacity(0.4) : Color.clear,
                                in: RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(Color.cardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                        .stroke(Color.inkBorder, lineWidth: 2)
                )
                .offset(y: triggerHeight + 6)
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
            }
        }
        // 3. Ensure this dropdown floats ABOVE views rendered below it in a VStack
        .zIndex(isExpanded ? 10 : 0)
    }
}

#Preview("Floating Dropdown") {
    struct PreviewWrapper: View {
        @State private var selectedTerm = "Semester 2, 2026"
        private let terms = [
            "Semester 1, 2026",
            "Semester 2, 2026",
            "Summer Semester, 2026"
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Teaching Period")
                    .font(.fredoka(.headline))
                    .foregroundStyle(Color.textPrimary)

                FloatingDropdown(
                    options: terms,
                    selection: $selectedTerm
                ) { term in
                    term
                }

                // Content directly below to test floating overlap & zIndex
                Card {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CSSE1001")
                            .font(.fredoka(.headline))
                            .foregroundStyle(Color.textPrimary)

                        Text("This card sits directly below the dropdown. Opening the menu should float cleanly on top of this card without shifting it.")
                            .font(.fredoka(.footnote))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(Color.screenBackground)
        }
    }

    return PreviewWrapper()
}

