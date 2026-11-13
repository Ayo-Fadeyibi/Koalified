import SwiftUI

struct SplashView: View {

    let onFinish: () -> Void

    let letters = ["K", "O", "A", "L", "I", "F", "I", "E", "D"]

    let colours = [Color.mintFill, Color.tintPink, Color.tintAmber, Color.tintMint]

    // One entry per floating tile: which symbol, colour, tilt, and where it sits.
    private struct SplashIcon {
        let symbol: String
        let fill: Color
        let tilt: Double
        let x: CGFloat
        let y: CGFloat
    }

    private let icons = [
        SplashIcon(symbol: "calendar", fill: Color.tintPink, tilt: -10, x: -120, y: -130),
        SplashIcon(symbol: "alarm", fill: Color.tintAmber, tilt: 8, x: 125, y: -104),
        SplashIcon(symbol: "plus.forwardslash.minus", fill: Color.tintMint, tilt: 6, x: -115, y: 140),
        SplashIcon(symbol: "note.text", fill: Color.mintFill, tilt: -8, x: 120, y: 120)
    ]

    private let letterSpacing: CGFloat = 3
    private let maxTileSize: CGFloat = 44

    @State private var appeared = false

    /// Size of one letter tile so all the letters fit on the screen, whatever its width.
    /// Width left = screen width - side margins - gaps between tiles - room for each tile's hard shadow
    /// (every tile reserves `shadowOffset` of extra width, so it counts once per tile).
    private func tileSize(for screenWidth: CGFloat) -> CGFloat {
        let gaps = letterSpacing * CGFloat(letters.count - 1)
        let shadows = Layout.shadowOffset * CGFloat(letters.count)
        let available = screenWidth - 2 * Layout.screenPadding - gaps - shadows
        return min(available / CGFloat(letters.count), maxTileSize)
    }

    var body: some View {
        GeometryReader { geo in
            let tile = tileSize(for: geo.size.width)

            ZStack {

                // Tiles first, so the name and tagline draw on top of them.
                ForEach(icons.indices, id: \.self) { index in
                    IconTile(
                        symbolName: icons[index].symbol,
                        colorFill: icons[index].fill,
                        rotateDegrees: icons[index].tilt
                    )
                    .scaleEffect(appeared ? 1 : 0.2)
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                            .delay(0.8 + Double(index) * 0.1),
                        value: appeared
                    )
                    .offset(x: icons[index].x, y: icons[index].y)
                }

                VStack(spacing: 0) {

                    HStack(spacing: letterSpacing) {
                        ForEach(letters.indices, id: \.self) { index in
                            Text(letters[index])
                                .font(.fredoka(size: tile * 0.6, .bold))
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: tile, height: tile)
                                .neoBrutalist(
                                    backgroundColor: colours[index % colours.count],
                                    cornerRadius: Layout.radiusCard
                                )
                                .scaleEffect(appeared ? 1 : 0.2)
                                .opacity(appeared ? 1 : 0)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.6)
                                        .delay(Double(index) * 0.06),
                                    value: appeared
                                )
                        }
                    }

                    Text("Less chaos. More campus.")
                        .font(.fredoka(.headline, .medium))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(1.0), value: appeared)
                }
            }
            // GeometryReader pins its content top-left, so give the ZStack the full size to centre it.
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.screenBackground.ignoresSafeArea())
        .onAppear { appeared = true }
        .contentShape(Rectangle())
        .onTapGesture { onFinish() }
        .task {
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            onFinish()
        }
    }
}

#Preview {
    SplashView(onFinish: { print("splash done") })
}
