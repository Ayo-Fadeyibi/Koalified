//
//  ResultRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// A label on the left and a number on the right, used on the import result screen.
struct ResultRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.fredoka(.subheadline))
                .foregroundStyle(Color.inkPrimary)
            Spacer()
            Text("\(value)")
                .font(.fredoka(.subheadline, .semibold))
                .foregroundStyle(Color.inkPrimary)
        }
    }
}

#Preview {
    Card {
        ResultRow(label: "Added", value: 98)
    }
    .padding()
    .background(Color.canvas)
}
