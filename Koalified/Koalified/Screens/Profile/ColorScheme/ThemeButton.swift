//
//  ThemeButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct ThemeToggleButton: View {
    @AppStorage("appColorScheme") private var appColorScheme: AppColorScheme = .system
    @Environment(\.colorScheme) private var systemColorScheme

    private var isDark: Bool {
        appColorScheme == .dark || (appColorScheme == .system && systemColorScheme == .dark)
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                appColorScheme = isDark ? .light : .dark
            }
        } label: {
            HStack(spacing: 8) {
                Image(isDark ? "sun" : "moon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(isDark ? "Light Mode" : "Dark Mode")
                    .font(.fredoka(.subheadline, .bold))
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall)
        }
        .buttonStyle(.plain)
    }
}
