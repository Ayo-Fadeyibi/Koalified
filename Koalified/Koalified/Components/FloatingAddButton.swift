//
//  FloatingAddButton.swift
//  Koalified
//

import SwiftUI

/// The round mint "+" button that floats over the bottom-right of a screen.
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(Color.onMint)
                .frame(width: Layout.fabSize, height: Layout.fabSize)
                .neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: Layout.fabSize / 2)
        }
    }
}

#Preview {
    FloatingAddButton {}
        .padding()
}
