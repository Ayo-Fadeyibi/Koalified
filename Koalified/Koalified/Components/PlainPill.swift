//
//  PlainPill.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//


import SwiftUI

/// Small pill-shaped button with the hard shadow, for filters and inline actions ("Current", "Add mark").
/// Pass `bgColor` to tint it, for example when it is the selected filter.
struct PlainPill: View {
    let title: LocalizedStringKey
    var color: Color = Color.textPrimary
    var bgColor: Color = Color.cardSurface
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 8
    
    
    var body: some View {
        HStack {
            Text(title)
                .font(.fredoka(.footnote, .bold))
                .foregroundStyle(color)
                
        }.padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(bgColor, in: RoundedRectangle(cornerRadius: Layout.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusLarge)
                    .strokeBorder(Color.inkBorder, lineWidth: 2)
            )
    }
}

#Preview {
    HStack {
        PlainPill(title: "Current", bgColor: Color.tintMint)
        PlainPill(title: "Add mark")
    }
    .padding()
}
