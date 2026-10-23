import SwiftUI

struct TimetableHelpView: View {
    let onShowMe: () -> Void
    let onHaveIt: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 3 of 3")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            Text("Do you need help finding your timetable?")
                .foregroundStyle(Color.inkPrimary)
                .fontWeight(.bold)
                .font(.largeTitle)
            Text("Koalified can read your UQ timetable from a link or a downloaded file. We'll show you where to find it.")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)

            VStack(spacing: 8) {
                optionRow(title: "Yes, show me how",
                          subtitle: "Find your timetable link or download the file",
                          action: onShowMe)
                optionRow(title: "No, I already have it",
                          subtitle: "Go straight to importing",
                          action: onHaveIt)
            }

            Spacer()

        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }

    // One tappable row: a title, a smaller line under it, and an arrow
    private func optionRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.inkPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.inkSecondary)
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimetableHelpView(onShowMe: {}, onHaveIt: {})
}
