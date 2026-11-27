//
//  HelpFeedbackView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

/// Help & feedback, pushed from the Profile tab: timetable import help, common questions
/// and a way to email feedback.
struct HelpFeedbackView: View {
    @Environment(\.openURL) private var openURL

    @State private var showImport = false
    @State private var showNoMailAlert = false
    /// The question that is open; only one answer shows at a time.
    @State private var openQuestion: FAQ.ID?

    private static let feedbackEmail = "fadeyibi2016@gmail.com"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Help & feedback")
                .primaryTextStyling()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    timetableSection
                    questionsSection
                    feedbackSection
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .mainContainerStyling()
        .sheet(isPresented: $showImport) { ImportLinkSheet().sheetBorder() }
        .alert("Couldn't open Mail", isPresented: $showNoMailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Email your feedback to \(Self.feedbackEmail).")
        }
    }

    // MARK: - Timetable

    /// How to find the UQ timetable link, with the import button right below the steps.
    private var timetableSection: some View {
        PlainCard {
            sectionHeading("Import your timetable")

            Text("You do this on UQ's own page. Koalified never sees your UQ password.")
                .secondaryTextStyling()

            ForEach(Array(SampleData.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.fredoka(.caption, .bold))
                        .foregroundStyle(Color.accent)
                        .frame(width: 24, height: 24)
                        .background(Color.greenDeep.opacity(0.12), in: Circle())
                    Text(step)
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(Color.textPrimary)
                }
            }

            PrimaryButton(title: "Paste link or choose file") { showImport = true }
        }
    }

    // MARK: - Questions

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeading("Common questions")

            ForEach(FAQ.all) { faq in
                FAQRow(faq: faq, isOpen: openQuestion == faq.id) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        openQuestion = openQuestion == faq.id ? nil : faq.id
                    }
                }
            }
        }
    }

    // MARK: - Feedback

    private var feedbackSection: some View {
        PlainCard {
            Text("Something not right?")
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Found a bug or have an idea? Send us a note. We read every message.")
                .secondaryTextStyling()

            PrimaryButton(title: "Send feedback") { sendFeedback() }
        }
    }

    private func sectionHeading(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.fredoka(.title3, .bold))
            .foregroundStyle(Color.textPrimary)
    }

    /// Opens a new email with the app and iOS versions filled in, so bug reports arrive with context.
    private func sendFeedback() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = Self.feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Koalified feedback"),
            URLQueryItem(name: "body", value: "\n\n---\nKoalified \(version) (\(build)), iOS \(UIDevice.current.systemVersion)")
        ]
        guard let url = components.url else { return }

        // No mail app set up: tell the student where to write instead.
        openURL(url) { accepted in
            if !accepted { showNoMailAlert = true }
        }
    }
}

/// One question and its answer.
private struct FAQ: Identifiable {
    let id: Int
    let question: LocalizedStringKey
    let answer: LocalizedStringKey

    static let all = [
        FAQ(id: 0,
            question: "Where is my data stored?",
            answer: "Only on this phone. Your courses and marks aren't synced to iCloud, and your timetable link is kept in the Keychain so it isn't copied to backups or a new phone."),
        FAQ(id: 1,
            question: "Why am I not getting reminders?",
            answer: "Check that notifications are allowed for Koalified in the Settings app, and that reminders are turned on under Profile > Notifications."),
        FAQ(id: 2,
            question: "My timetable didn't import. What now?",
            answer: "Make sure you copied the whole calendar link, or try downloading the .ics file and choosing it instead. If it still fails, send us feedback below.")
    ]
}

/// Tappable question that expands to show its answer.
private struct FAQRow: View {
    let faq: FAQ
    let isOpen: Bool
    let toggle: () -> Void

    var body: some View {
        Button {
            toggle()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(faq.question)
                        .font(.fredoka(.body, .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                }

                if isOpen {
                    Text(faq.answer)
                        .secondaryTextStyling()
                        .multilineTextAlignment(.leading)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .plainStyling()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(isOpen ? "Hides the answer" : "Shows the answer")
    }
}

#Preview {
    NavigationStack {
        HelpFeedbackView()
    }
}
