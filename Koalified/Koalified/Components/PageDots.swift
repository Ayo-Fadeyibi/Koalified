//
//  PageDots.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 1/11/2026.
//

import SwiftUI

struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.brandMint : Color.tintMint.opacity(0.3))
                    .frame(width: index == current ? 32 : 14, height: 14)
                    .overlay(Capsule().strokeBorder(Color.textPrimary, lineWidth: 3))
            }
        }.animation(.snappy, value: current)
    }
}

#Preview {
    PageDots(count: 3, current: 0)
}
