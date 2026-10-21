//
//  SecondaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//
import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.inkPop)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.inkPop, lineWidth: 2)
                }
        }
    }
}

#Preview {
    SecondaryButton(title: "Hello World") {}
}
