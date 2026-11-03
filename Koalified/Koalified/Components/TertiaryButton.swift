//
//  TertiaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 29/10/2026.
//

import SwiftUI

struct TertiaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.inkPop)
                .frame(maxWidth: .infinity)
                .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: Color.inkPop, lWidth: 2)
                
        }.buttonStyle(.plain)
    }
}

#Preview {
    TertiaryButton(title: "Hello"){}
}
