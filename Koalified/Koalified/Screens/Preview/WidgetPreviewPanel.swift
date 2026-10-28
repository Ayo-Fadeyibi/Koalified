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
                colors: [Color.startGradient, Color.endGradient],
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
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))

            Text("CSSE1001")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)

            Text("Lecture")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text("in 20 min")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text("Room 50-201")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.inkPop, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
    }
}

/// Light tile showing the next assessment due: title, course and weight, and days left.
private func dueSoonWidget() -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text("DUE SOON")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.accentText.opacity(0.8))

        Text("Problem set 3")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.inkPrimary)

        Text("MATH1051 15%")
            .font(.system(size: 12))
            .foregroundStyle(Color.inkSecondary.opacity(0.8))

        Spacer()

        Text("1 day left")
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.inkPrimary)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
}


#Preview {
    WidgetPreviewPanel()
}
