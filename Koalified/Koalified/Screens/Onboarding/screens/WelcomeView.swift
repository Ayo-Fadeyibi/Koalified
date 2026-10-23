//
//  WelcomeView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//
import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            // koala image here: Image("koala").resizable().scaledToFit().frame(width: 220)
            Text("Welcome to Koalified")
                .font(.largeTitle.weight(.bold))
            Text("Your semester, sorted.")
                .foregroundStyle(Color.inkSecondary)
            Spacer()
            PrimaryButton(title: "Let's Go", action: onNext)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.canvas)
    }
}

#Preview {
    WelcomeView(onNext: {})
}
