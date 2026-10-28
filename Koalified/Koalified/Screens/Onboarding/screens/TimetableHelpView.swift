import SwiftUI

/// Onboarding step 3: asks whether the user needs help finding their timetable.
/// They can be shown how, go straight to importing, or skip and finish onboarding.
struct TimetableHelpView: View {
    /// Called for "Yes, show me how".
    let onShowMe: () -> Void
    /// Called for "No, I already have it".
    let onHaveIt: () -> Void

    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 3 of 3")
                .secondaryTextStyling()
            Text("Do you need help finding your timetable?")
                .primaryTextStyling()
            Text("Koalified can read your UQ timetable from a link or a downloaded file. We'll show you where to find it.")
                .secondaryTextStyling()

            VStack(spacing: 8) {
                optionRow(title: "Yes, show me how",
                          subtitle: "Find your timetable link or download the file",
                          action: onShowMe)
                optionRow(title: "No, I already have it",
                          subtitle: "Go straight to importing",
                          action: onHaveIt)
            }

            Spacer()
            
            PrimaryButton(title: "I'll add it later"){finish()}

        }
        .mainContainerStyling()
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
            .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: Color.cardBorder, lWidth: 1)
        }
        .buttonStyle(.plain)
    }
    
    // Marks onboarding as complete so RootView shows the main tabs.
    private func finish() {
        hasOnboarded = true
    }
}

#Preview {
    TimetableHelpView(onShowMe: {}, onHaveIt: {})
}
