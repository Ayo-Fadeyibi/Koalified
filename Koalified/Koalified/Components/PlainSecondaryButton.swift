//
//  PlainSecondaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 17/11/2026.
//

import SwiftUI

struct PlainSecondaryButton: View {
    let title: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.fredoka(.body, .semibold))
                        .foregroundStyle(Color.textPrimary)
                        
                    if let message {
                        Text(message)
                            .font(.fredoka(.body))
                            .secondaryTextStyling()
                    }
                }

                Spacer()
                
                Text(">")
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
            }.padding()
                .frame(maxWidth: .infinity)
                .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .strokeBorder(Color.inkBorder, lineWidth: 2)
                )
        }.buttonStyle(.plain)
    }
}

#Preview {
    PlainSecondaryButton(title: "Hello World", message: "Hello......") {}
        .padding()
}
