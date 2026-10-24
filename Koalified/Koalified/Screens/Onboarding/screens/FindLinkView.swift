import SwiftUI

struct FindLinkView: View {
    let onImport: () -> Void

    let steps = [
        "Open your timetable on UQ's website and sign in there.",
        "Look for the option to export or download your calendar (an .ics file, or a calendar link).",
        "Copy the link, or save the file to your phone.",
        "Come back here and paste the link, or choose the file."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Find your timetable link")
                .foregroundStyle(Color.inkPrimary)
                .fontWeight(.bold)
                .font(.largeTitle)

            Text("You do this on UQ's own page. Koalified never sees your UQ password.")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)

            // Numbered steps in a card
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
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
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusCard))
            .overlay {
                RoundedRectangle(cornerRadius: Layout.radiusCard)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            }

            Spacer()

            PrimaryButton(title: "Paste link or choose file", action: onImport)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    FindLinkView(onImport: {})
}
