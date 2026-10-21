//
//  PrimaryButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button (action: action) {
            Text(title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.inkPop)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    PrimaryButton(title: "Continue") { print("tapped") }
}
