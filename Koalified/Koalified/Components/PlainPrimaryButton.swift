//
//  plainPrimaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct PlainPrimaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    /// Corner radius of the button. Pass a large value for a pill shape.
    var cornerRadius: CGFloat = Layout.radiusLarge
    var colour: Color? = nil
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.onMint)
                .padding()
                .frame(maxWidth: .infinity)
                .background(colour ?? Color.mintFill, in: RoundedRectangle(cornerRadius: Layout.radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusLarge)
                        .strokeBorder(Color.inkBorder, lineWidth: 2)
                )
        }
    }
}


#Preview{
    PlainPrimaryButton(title: "Something something"){}
}
