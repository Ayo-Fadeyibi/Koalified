//
//  IconTile.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 2/11/2026.
//

import SwiftUI

struct IconTile: View {
    
    let symbolName: String
    let colorFill: Color
    let rotateDegrees: Double
    
    var body: some View {
            Image(systemName: symbolName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 64, height: 64)
            .boxStyling(bgColor: colorFill, cRadius: Layout.radiusCard, sColor: Color.cardBorder, lWidth: 1)
            .rotationEffect(.degrees(rotateDegrees))
    }
}

#Preview {
    IconTile(symbolName: "calendar", colorFill: Color.brandMint, rotateDegrees: -8)
}
