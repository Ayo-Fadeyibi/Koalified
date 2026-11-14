//
//  SplitFlapDisplay.swift.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

import SwiftUI

struct SplitFlapDisplay: View {
    let text: String
    var tileBackground: Color = Color(red: 0.11, green: 0.16, blue: 0.14)
    var seamColor: Color = Color(red: 0.25, green: 0.34, blue: 0.30)

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                SplitFlapTile(
                    character: String(character),
                    staggerDelay: Double(index) * 0.05,
                    tileBackground: tileBackground,
                    seamColor: seamColor
                )
            }
        }
    }
}


/// Renders either the top or bottom half of a single tile by clipping a full-height tile.
private struct HalfFlapView: View {
    enum Half { case top, bottom }

    let character: String
    let half: Half
    let tileBackground: Color

    var body: some View {
        Text(character)
            .font(.system(size: 32, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(tileBackground)
            .mask(
                VStack(spacing: 0) {
                    if half == .top {
                        Color.black
                        Color.clear
                    } else {
                        Color.clear
                        Color.black
                    }
                }
            )
    }
}


struct SplitFlapTile: View {
    let character: String
    var staggerDelay: Double = 0
    let tileBackground: Color
    let seamColor: Color

    @State private var currentChar: String = " "
    @State private var nextChar: String = " "
    @State private var topFlipAngle: Double = 0
    @State private var bottomFlipAngle: Double = 90
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            // 1. Background Top Half
            HalfFlapView(character: nextChar, half: .top, tileBackground: tileBackground)

            // 2. Background Bottom Half
            HalfFlapView(character: currentChar, half: .bottom, tileBackground: tileBackground)

            // 3. Animated Top Flap
            HalfFlapView(character: currentChar, half: .top, tileBackground: tileBackground)
                .rotation3DEffect(
                    .degrees(topFlipAngle),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center,
                    perspective: 0.5
                )
                .overlay(
                    Color.black.opacity(abs(topFlipAngle) / 90.0 * 0.35)
                        .allowsHitTesting(false)
                )

            // 4. Animated Bottom Flap
            HalfFlapView(character: nextChar, half: .bottom, tileBackground: tileBackground)
                .rotation3DEffect(
                    .degrees(bottomFlipAngle),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .center,
                    perspective: 0.5
                )

            // 5. Center Hinge Seam Line
            Rectangle()
                .fill(seamColor)
                .frame(height: 1.5)
        }
        .frame(height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + staggerDelay) {
                triggerFlip(to: character)
            }
        }
        .onChange(of: character) { _, newValue in
            guard newValue != currentChar else { return }
            triggerFlip(to: newValue)
        }
    }

    private func triggerFlip(to newValue: String) {
        nextChar = newValue
        topFlipAngle = 0
        bottomFlipAngle = 90

        withAnimation(.easeIn(duration: 0.16)) {
            topFlipAngle = -90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation(.easeOut(duration: 0.18)) {
                bottomFlipAngle = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            currentChar = newValue
            topFlipAngle = 0
            bottomFlipAngle = 90
        }
    }
}


#Preview("Animated Split Flap") {
    struct PreviewWrapper: View {
        @State private var code = "50-201"

        var body: some View {
            VStack(spacing: 24) {
                SplitFlapDisplay(text: code)

                Button {
                    let randomNum = Int.random(in: 100...999)
                    code = "50-\(randomNum)"
                } label: {
                    Text("Flip Numbers")
                        .font(.fredoka(.subheadline, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.mintFill)
        }
    }

    return PreviewWrapper()
}


