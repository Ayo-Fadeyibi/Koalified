import SwiftUI

/// Onboarding help screen with numbered steps for exporting the UQ timetable link or file.
struct FindLinkView: View {
    /// Called when the user is ready to paste the link or choose the file.
    let onImport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Find your timetable link")
                .primaryTextStyling()
            
            Text("You do this on UQ's own page. Koalified never sees your UQ password.")
                .secondaryTextStyling()

            // Numbered steps in a card
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(SampleData.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.accentText)
                            .frame(width: 24, height: 24)
                            .background(Color.inkPop.opacity(0.12), in: Circle())
                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(Color.inkPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusCard, sColor: Color.cardBorder,lWidth: 1)

            Spacer()

            PrimaryButton(title: "Paste link or choose file", action: onImport)
        }
        .mainContainerStyling()
        
    }
}

#Preview {
    FindLinkView(onImport: {})
}
