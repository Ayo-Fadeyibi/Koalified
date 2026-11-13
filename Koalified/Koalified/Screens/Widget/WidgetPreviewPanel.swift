import SwiftUI

/// Mock-up of the "Next class" and "Due soon" widgets on a gradient background,
/// used to show the user what the widgets will look like. Shows sample data.
struct WidgetPreviewPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12){
                nextClassWidget()
                dueSoonWidget()
            }.frame(height: 150)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 301)
        .background(
            LinearGradient(
                colors: [Color.gradientStart, Color.mintFill],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.6, y: 0.8)
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    /// Dark tile showing the next class: course, type, time until it starts and room.
    private func nextClassWidget() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("NEXT CLASS")
                .font(.fredoka(size: 11, .semibold))
                .foregroundStyle(.white.opacity(0.8))

            Text("CSSE1001")
                .font(.fredoka(size: 22, .bold))
                .foregroundStyle(.white)

            Text("Lecture")
                .font(.fredoka(size: 12))
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text("in 20 min")
                .font(.fredoka(size: 17, .semibold))
                .foregroundStyle(.white)

            Text("Room 50-201")
                .font(.fredoka(size: 11))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.greenDeep, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
    }
}

/// Light tile showing the next assessment due: title, course and weight, and days left.
private func dueSoonWidget() -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text("DUE SOON")
            .font(.fredoka(size: 11, .semibold))
            .foregroundStyle(Color.accent.opacity(0.8))

        Text("Problem set 3")
            .font(.fredoka(size: 17, .bold))
            .foregroundStyle(Color.textPrimary)

        Text("MATH1051 15%")
            .font(.fredoka(size: 12))
            .foregroundStyle(Color.textSecondary.opacity(0.8))

        Spacer()

        Text("1 day left")
            .font(.fredoka(size: 17, .semibold))
            .foregroundStyle(Color.textPrimary)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
}


#Preview {
    WidgetPreviewPanel()
}
