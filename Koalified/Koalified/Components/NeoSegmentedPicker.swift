//
//  NeoSegmentedPicker.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

struct NeoSegmentedPicker: View {
    let options: [String]
    @Binding var selection: String
    @Namespace private var animationNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selection = option
                    }
                } label: {
                    Text(LocalizedStringKey(option))
                        .font(.fredoka(.subheadline, isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Color.onMint : Color.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                                    .fill(Color.mintFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                                            .stroke(Color.inkBorder, lineWidth: 1.5)
                                    )
                                    .matchedGeometryEffect(id: "ACTIVE_SEGMENT", in: animationNamespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.cardSurface)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                .stroke(Color.inkBorder, lineWidth: 2)
        )
    }
}

#Preview("Neo Segmented Picker") {
    struct PreviewWrapper: View {
        @State private var selectedView = "Current"
        private let options = ["Current", "All Courses", "Archived"]

        var body: some View {
            VStack(spacing: 20) {
                NeoSegmentedPicker(options: options, selection: $selectedView)
                
                Text("Showing: \(selectedView)")
                    .font(.fredoka(.footnote))
                    .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
            .background(Color.screenBackground)
        }
    }

    return PreviewWrapper()
}
