//
//  RemoveTimetableLinkView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

/// Remove timetable link, pushed from the Profile tab. Deletes the private UQ timetable link from the
/// Keychain and signs out of UQ inside Koalified. Imported classes, courses and marks are kept;
/// Delete semester data is the place to remove those.
struct RemoveTimetableLinkView: View {

    /// The link in the Keychain; nil when none is saved. Read on appear and after importing.
    @State private var savedLink: URL?
    @State private var showConfirm = false
    @State private var showImport = false
    @State private var showRemoved = false
    /// True while the link and UQ sign-in are being cleared.
    @State private var isRemoving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Remove timetable link")
                .primaryTextStyling()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let savedLink {
                        linkedContent(savedLink)
                            .appearAnimation()
                    } else {
                        notLinkedContent
                            .appearAnimation()
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .mainContainerStyling()
        .onAppear { savedLink = TimetableLinkStore.load() }
        .confirmationDialog("Remove your timetable link?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Remove link", role: .destructive) {
                Task { await removeLink() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your classes and marks stay. You can import your timetable again at any time.")
        }
        .sheet(isPresented: $showImport, onDismiss: { savedLink = TimetableLinkStore.load() }) {
            ImportLinkSheet().sheetBorder()
        }
        .loadingOverlay(isPresented: isRemoving, message: "Removing your link…")
        .PopUp(isPresented: $showRemoved, message: "Timetable link removed", image: "circle-check", colour: Color.mintFill, feedback: .success)
    }

    // MARK: - Linked

    private func linkedContent(_ link: URL) -> some View {
        Group {
            PlainCard(bgColor: Color.tintMint) {
                Text("Your timetable is linked")
                    .font(.fredoka(.title3, .bold))
                    .foregroundStyle(Color.textPrimary)

                // Only the host: the full link is private, anyone holding it can read the timetable
                Text("Saved securely on this phone from \(link.host() ?? "your university").")
                    .secondaryTextStyling()
            }

            PlainCard {
                Text("What happens when you remove it")
                    .font(.fredoka(.title3, .bold))
                    .foregroundStyle(Color.textPrimary)

                InfoRow(icon: "circle-x", text: "The private link is deleted from this phone.")
                InfoRow(icon: "circle-x", text: "You're signed out of UQ inside Koalified.")
                InfoRow(icon: "circle-check", text: "Your classes, courses and marks stay as they are.")
                InfoRow(icon: "circle-check", text: "You can import your timetable again at any time.")
            }

            Text("To remove your classes and marks too, use Delete semester data in your profile.")
                .secondaryTextStyling()

            PrimaryButton(title: "Delete", action: {showConfirm = true}, bgColor: Color.redFill)
        }
    }

    // MARK: - Not linked

    private var notLinkedContent: some View {
        Group {
            PlainCard {
                Text("No timetable linked")
                    .font(.fredoka(.title3, .bold))
                    .foregroundStyle(Color.textPrimary)

                Text("There's no timetable link saved on this phone. Any classes you've added or imported are still in the app.")
                    .secondaryTextStyling()
            }

            PrimaryButton(title: "Import your timetable") {
                showImport = true
            }
        }
    }

    // MARK: - Actions

    /// Deletes the link and clears the UQ sign-in, the same cleanup as the import sheet's Sign out.
    private func removeLink() async {
        isRemoving = true
        defer { isRemoving = false }
        TimetableLinkStore.delete()
        TimetableWebSession.end()
        await TimetableWebView.signOut()
        withAnimation { savedLink = nil }
        showRemoved = true
    }
}

/// An icon followed by one line of explanation.
private struct InfoRow: View {
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.textPrimary)
                .accessibilityHidden(true)

            Text(text)
                .font(.fredoka(.subheadline))
                .foregroundStyle(Color.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        RemoveTimetableLinkView()
    }
}
