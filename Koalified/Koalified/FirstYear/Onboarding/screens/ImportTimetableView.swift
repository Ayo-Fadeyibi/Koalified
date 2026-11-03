//
//  ImportTimetableView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// The import start screen: paste a timetable link or choose an .ics file, with a privacy note.
/// In onboarding it also shows the step label and a skip option.
struct ImportTimetableView: View {
    let errorMessage: String?
    var isOnboarding = false
    let onImportLink: (String) -> Void
    let onChooseFile: () -> Void
    var onSkip: (() -> Void)? = nil

    /// The pasted timetable link. Only kept in memory, never stored.
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if isOnboarding {
                Text("Step 2 of 2")
                    .secondaryTextStyling()
                    .padding(.bottom, -12)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Bring in your timetable")
                    .font(.fredoka(.largeTitle, .bold))
                    .foregroundStyle(Color.newInk)
                Text("Paste your UQ timetable link or upload the .ics file. No login needed.")
                    .secondaryTextStyling()
            }

            // Paste-a-link card
            VStack(alignment: .leading, spacing: 14) {
                Text("Paste a link")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.newInk)
                // Flat field: thin border, no hard shadow, so it reads as an input inside the card.
                TextField("", text: $link, prompt: Text("https://...").foregroundStyle(Color.inkSecondary))
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.newInk)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(14)
                    .neoBrutalist(backgroundColor: Color.newInk.opacity(0.05),
                                  cornerRadius: Layout.radiusSmall,
                                  shadowOffset: 0,
                                  shadowColor: .clear)
                pillButton("Import from link", fill: Color.endGradient) { onImportLink(link) }
            }
            .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusLarge, sColor: Color.cardBorder, lWidth: 1)

            pillButton("Choose a .ics file", fill: Color.inkMint, action: onChooseFile)

            // Privacy note
            VStack(alignment: .leading, spacing: 6) {
                Text("Your link stays on this phone")
                    .font(.fredoka(.subheadline, .bold))
                    .foregroundStyle(Color.newInk)
                Text("Import again any time. Changes update, nothing gets duplicated.")
                    .font(.fredoka(.footnote))
                    .foregroundStyle(Color.newInk.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .boxStyling(bgColor: Color.warmFill, cRadius: Layout.radiusLarge, sColor: Color.cardBorder, lWidth: 1)

            if let errorMessage {
                Text(errorMessage)
                    .font(.fredoka(.footnote, .semibold))
                    .foregroundStyle(Color.roseFill)
            }

            Spacer()
            if let onSkip {
                Button(action: onSkip) {
                    Text("Skip, I'll add classes by hand")
                        .font(.fredoka(.subheadline, .bold))
                        .foregroundStyle(Color.accentText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }

    /// Full-width pill button: thick border and hard shadow, dark label.
    private func pillButton(_ title: LocalizedStringKey, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.newInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .neoBrutalist(backgroundColor: fill, cornerRadius: 30)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ImportTimetableView(errorMessage: nil, isOnboarding: true, onImportLink: { _ in }, onChooseFile: {}, onSkip: {})
        .mainContainerStyling()
}
