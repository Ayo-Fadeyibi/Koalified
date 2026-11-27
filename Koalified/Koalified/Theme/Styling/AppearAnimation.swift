//
//  AppearAnimation.swift
//  Koalified
//
//  Fades a view in and lifts it into place the first time it appears.
//

import SwiftUI

/// Plays once per view: later appearances (switching back to a tab, popping back to a screen) show the
/// view straight away. With Reduce Motion on, the view only fades.
private struct AppearAnimation: ViewModifier {
    let delay: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShown = false

    func body(content: Content) -> some View {
        content
            .opacity(isShown ? 1 : 0)
            .offset(y: isShown || reduceMotion ? 0 : 14)
            .onAppear {
                guard !isShown else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85).delay(delay)) {
                    isShown = true
                }
            }
    }
}

extension View {
    /// Fades and lifts the view in when it first appears. Give sections on the same screen increasing
    /// `order` values (0, 1, 2…) so they arrive one after another instead of all at once.
    func appearAnimation(order: Int = 0) -> some View {
        // Capped so a long list doesn't keep the last rows waiting
        modifier(AppearAnimation(delay: Double(min(order, 8)) * 0.06))
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(0..<4) { index in
            PlainCard { Text("Card \(index + 1)") }
                .appearAnimation(order: index)
        }
    }
    .padding()
    .background(Color.screenBackground)
}
