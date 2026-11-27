//
//  LoadingOverlay.swift
//  Koalified
//

import SwiftUI

/// Covers the screen with a dimmed backdrop and a small card ("Fetching your timetable…") while
/// `isPresented` is true. Taps are blocked straight away so an action can't be started twice, but the
/// card only appears if the work is still running after `showDelay`, so quick actions never flash it.
/// Once shown it stays for at least `minimumShowTime`, so it doesn't blink on and off.
private struct LoadingOverlay: ViewModifier {
    let isPresented: Bool
    let message: LocalizedStringKey

    private let showDelay: Duration = .milliseconds(400)
    private let minimumShowTime: Duration = .milliseconds(500)

    @State private var isVisible = false
    @State private var shownAt: ContinuousClock.Instant?

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented || isVisible {
                    ZStack {
                        Color.black.opacity(isVisible ? 0.3 : 0)
                            .ignoresSafeArea()

                        if isVisible {
                            card
                                .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }
                    }
                    // Catches taps even before the card shows
                    .contentShape(Rectangle())
                }
            }
            .task(id: isPresented) {
                if isPresented {
                    try? await Task.sleep(for: showDelay)
                    guard !Task.isCancelled else { return }
                    shownAt = .now
                    withAnimation(.easeOut(duration: 0.2)) { isVisible = true }
                } else if isVisible {
                    if let shownAt {
                        let remaining = minimumShowTime - (ContinuousClock.now - shownAt)
                        if remaining > .zero { try? await Task.sleep(for: remaining) }
                    }
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeIn(duration: 0.2)) { isVisible = false }
                    shownAt = nil
                }
            }
    }

    private var card: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.textPrimary)

            Text(message)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(minWidth: 180)
        .plainStyling()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

extension View {
    /// Shows a loading card over this view while `isPresented` is true and the work takes longer
    /// than a moment. Use for actions that wait on the network or the system.
    func loadingOverlay(isPresented: Bool, message: LocalizedStringKey) -> some View {
        modifier(LoadingOverlay(isPresented: isPresented, message: message))
    }
}

#Preview {
    Text("Behind the overlay")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.screenBackground)
        .loadingOverlay(isPresented: true, message: "Fetching your timetable…")
}
