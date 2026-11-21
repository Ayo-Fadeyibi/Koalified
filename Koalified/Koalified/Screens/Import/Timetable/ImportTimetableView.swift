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
    var isOnboarding = false
    let onImportLink: (String) -> Void
    let onChooseFile: () -> Void
    var onSkip: (() -> Void)? = nil

    /// The pasted timetable link. Only kept in memory, never stored.
    @State private var link = ""
    
    @State private var showWebView = false

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
                PlainPrimaryButton(title: "Import from link") { onImportLink(link) }
            }

            PrimaryButton(title: "Choose a .ics file", action: onChooseFile, bgColor: Color.tintPink)
                .padding(.bottom, 10)
            
            // UQ Sign-In Fallback Section
            PlainCard(bgColor: Color.cardSurface) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Don't have your link?")
                            .font(.fredoka(.body, .bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Sign in to UQ inside Koalified and we'll find your timetable. Your password goes to UQ, never to us.")
                            .secondaryTextStyling()
                            .fixedSize(horizontal: false, vertical: true)
                    }

                   SecondaryButton(title: "UQ Sign In") {
                        showWebView = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            // Privacy Note (Pinned to Bottom)
            PlainCard(bgColor: Color.tintAmber) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Your link stays on this phone", systemImage: "lock.fill")
                        .font(.fredoka(.subheadline, .bold))
                        .foregroundStyle(Color.textPrimary)

                    Text("Import again any time. Changes update, nothing gets duplicated.")
                        .font(.fredoka(.footnote, .medium))
                        .foregroundStyle(Color.textPrimary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
        .sheet(isPresented: $showWebView) {
            ImportSheet(
                onLink: { found in
                    showWebView = false
                    onImportLink(found)
                },
                onDone: { showWebView = false }
            )
        }
    }
}

#Preview {
    ImportTimetableView(isOnboarding: true, onImportLink: { _ in }, onChooseFile: {}, onSkip: {})
        .mainContainerStyling()
}
