//
//  SelectableRow.swift
//  Koalified
//

import SwiftUI

/// A tappable choice in a list (language, year, university). The selected row is a mint-tinted `Card`
/// with the hard shadow and a checkmark; every other row is a flat `PlainCard`.
struct SelectableRow<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    let content: Content

    init(isSelected: Bool, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }

    private var row: some View {
        HStack {
            content
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(Color.accent)
            }
        }
    }

    var body: some View {
        Button(action: action) {
            if isSelected {
                Card(bgColor: Color.tintMint) { row }
            } else {
                PlainCard { row }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selected = 1
    VStack(spacing: 12) {
        ForEach(1...3, id: \.self) { value in
            SelectableRow(isSelected: selected == value, action: { selected = value }) {
                Text("Option \(value)").font(.fredoka(.body, .semibold))
            }
        }
    }
    .padding()
}
