//
//  StartImportView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// First import screen: paste a timetable link or open the file picker.
/// In onboarding it shows the step label and a skip option.
struct StartImportView: View {
    let errorMessage: String?
    var isOnboarding = false
    let onImportLink: (String) -> Void
    let onChooseFile: () -> Void
    var onSkip: (() -> Void)? = nil

    /// The pasted timetable link. Only kept in memory, never stored.
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            if isOnboarding {
                Text("Step 2 of 2")
                    .secondaryTextStyling()
            }
            Text(isOnboarding ? "Bring in your timetable" : "Import your timetable")
                .primaryTextStyling()
            Text("Paste your UQ timetable link or upload the .ics file. No login needed.")
                .secondaryTextStyling()

            Card {
                Text("Paste a link")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)
                TextField("https://...", text: $link)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .boxStyling(bgColor: Color.cardSurface, cRadius: Layout.radiusSmall, sColor: Color.cardBorder, lWidth: 1)
                PrimaryButton(title: "Import from link") { onImportLink(link) }
                    .disabled(link.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            SecondaryButton(title: "Choose a .ics file", action: onChooseFile)

            if let errorMessage {
                Text(errorMessage)
                    .font(.fredoka(.footnote, .semibold))
                    .foregroundStyle(Color.errorText)
            }

            Spacer()
            PrivacyNote()
            if let onSkip {
                TertiaryButton(title: "Skip, I'll add classes by hand", action: onSkip)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }
}

#Preview {
    StartImportView(errorMessage: nil, isOnboarding: true, onImportLink: { _ in }, onChooseFile: {}, onSkip: {})
        .mainContainerStyling()
}
