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
                    .foregroundStyle(Color.textPrimary)
                Text("Paste your UQ timetable link or upload the .ics file. No login needed.")
                    .secondaryTextStyling()
            }

            // Paste-a-link card
            PlainCard {
                Text("Paste a link")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)
                // Flat field: thin border, no hard shadow, so it reads as an input inside the card.
                TextField("", text: $link, prompt: Text("https://...").foregroundStyle(Color.textSecondary))
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(14)
                    .neoBrutalist(backgroundColor: Color.textPrimary.opacity(0.05),
                                  cornerRadius: Layout.radiusSmall,
                                  shadowOffset: 0,
                                  shadowColor: .clear)
                PrimaryButton(title: "Import from link") { onImportLink(link) }
            }

            PrimaryButton(title: "Choose a .ics file", action: onChooseFile, bgColor: Color.tintMint)

            // Privacy note
            PlainCard(bgColor: Color.tintAmber) {
                Text("Your link stays on this phone")
                    .font(.fredoka(.subheadline, .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("Import again any time. Changes update, nothing gets duplicated.")
                    .font(.fredoka(.footnote))
                    .foregroundStyle(Color.textPrimary.opacity(0.75))
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.fredoka(.footnote, .semibold))
                    .foregroundStyle(Color.errorText)
            }

            Spacer()
            if let onSkip {
                TextButton(title: "Skip, I'll add classes by hand", font: .fredoka(.subheadline, .bold), action: onSkip)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }
}

#Preview {
    ImportTimetableView(errorMessage: nil, isOnboarding: true, onImportLink: { _ in }, onChooseFile: {}, onSkip: {})
        .mainContainerStyling()
}
