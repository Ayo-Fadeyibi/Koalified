//
//  EmptyStateView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Placeholder shown when a screen has no content. Two cards with an optional slot between them:
///
/// - Card 1: a small header, a title, a message, a primary button and a secondary row.
/// - `content`: anything extra (optional).
/// - Card 2: a header, title, message and button for a supporting note.
///
/// Every value is optional; a card with nothing to show is left out.
struct EmptyStateView<Content: View>: View {

    let content: Content

    let header1: LocalizedStringKey?
    let header2: LocalizedStringKey?
    let title1: LocalizedStringKey?
    let title2: LocalizedStringKey?
    let message1: LocalizedStringKey?
    let message2: LocalizedStringKey?
    let primaryTitle1: LocalizedStringKey?
    let primaryTitle2: LocalizedStringKey?
    let primaryAction1: (() -> Void)?
    let primaryAction2: (() -> Void)?
    let secondaryTitle: LocalizedStringKey?
    let secondaryAction: (() -> Void)?
    let secondaryTitle2: LocalizedStringKey?
    let secondaryAction2: (() -> Void)?

    init(
        header1: LocalizedStringKey? = nil,
        header2: LocalizedStringKey? = nil,
        title1: LocalizedStringKey? = nil,
        title2: LocalizedStringKey? = nil,
        message1: LocalizedStringKey? = nil,
        message2: LocalizedStringKey? = nil,
        primaryTitle1: LocalizedStringKey? = nil,
        primaryTitle2: LocalizedStringKey? = nil,
        primaryAction1: (() -> Void)? = nil,
        primaryAction2: (() -> Void)? = nil,
        secondaryTitle: LocalizedStringKey? = nil,
        secondaryAction: (() -> Void)? = nil,
        secondaryTitle2: LocalizedStringKey? = nil,
        secondaryAction2: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header1 = header1
        self.header2 = header2
        self.title1 = title1
        self.title2 = title2
        self.message1 = message1
        self.message2 = message2
        self.primaryTitle1 = primaryTitle1
        self.primaryTitle2 = primaryTitle2
        self.primaryAction1 = primaryAction1
        self.primaryAction2 = primaryAction2
        self.secondaryTitle = secondaryTitle
        self.secondaryAction = secondaryAction
        self.secondaryTitle2 = secondaryTitle2
        self.secondaryAction2 = secondaryAction2
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            if hasFirstCard {
                Card {
                    if let header1 { headerText(header1) }
                    if let title1 {
                        Text(title1)
                            .primaryTextStyling()
                    }
                    if let message1 { messageText(message1) }
                    if let primaryTitle1, let primaryAction1 {
                        PrimaryButton(title: primaryTitle1, action: primaryAction1, cornerRadius: 30)
                    }
                    if let secondaryTitle, let secondaryAction {
                        secondaryRow(secondaryTitle, action: secondaryAction)
                    }
                }
            }

            content

            if hasSecondCard {
                Card {
                    if let header2 { headerText(header2) }
                    if let title2 {
                        Text(title2)
                            .font(.fredoka(.title3, .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    if let message2 { messageText(message2) }
                    if let primaryTitle2, let primaryAction2 {
                        PrimaryButton(title: primaryTitle2, action: primaryAction2, cornerRadius: 30)
                    }
                    
                    if let secondaryTitle2, let secondaryAction2 {
                        secondaryRow(secondaryTitle2, action: secondaryAction2)
                    }
                }
            }
        }
    }

    // MARK: - Pieces

    private var hasFirstCard: Bool {
        header1 != nil || title1 != nil || message1 != nil || primaryTitle1 != nil || secondaryTitle != nil
    }

    private var hasSecondCard: Bool {
        header2 != nil || title2 != nil || message2 != nil || primaryTitle2 != nil || secondaryTitle2 != nil
    }

    /// Small monospaced all-caps label above a title.
    private func headerText(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.system(.caption, design: .monospaced).weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(Color.accent)
            .frame(maxWidth: .infinity, alignment: .leading)   // keeps both cards full width
    }

    private func messageText(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.fredoka(.body))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Flat bordered row with the label on the left and a chevron on the right.
    private func secondaryRow(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        SecondaryButton(title: title, action: action)
    }
}

/// Lets callers leave out the middle `content` slot.
extension EmptyStateView where Content == EmptyView {
    init(
        header1: LocalizedStringKey? = nil,
        header2: LocalizedStringKey? = nil,
        title1: LocalizedStringKey? = nil,
        title2: LocalizedStringKey? = nil,
        message1: LocalizedStringKey? = nil,
        message2: LocalizedStringKey? = nil,
        primaryTitle1: LocalizedStringKey? = nil,
        primaryTitle2: LocalizedStringKey? = nil,
        primaryAction1: (() -> Void)? = nil,
        primaryAction2: (() -> Void)? = nil,
        secondaryTitle: LocalizedStringKey? = nil,
        secondaryAction: (() -> Void)? = nil,
        secondaryTitle2: LocalizedStringKey? = nil,
        secondaryAction2: (() -> Void)? = nil
    ) {
        self.init(header1: header1, header2: header2,
                  title1: title1, title2: title2,
                  message1: message1, message2: message2,
                  primaryTitle1: primaryTitle1, primaryTitle2: primaryTitle2,
                  primaryAction1: primaryAction1, primaryAction2: primaryAction2,
                  secondaryTitle: secondaryTitle, secondaryAction: secondaryAction,
                  secondaryTitle2: secondaryTitle2, secondaryAction2: secondaryAction2
        ) {
            EmptyView()
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.screenBackground.ignoresSafeArea()
        EmptyStateView(
            header1: "Welcome to your semester",
            title1: "Your day starts here.",
            title2: "Check it before you keep it",
            message1: "Import your timetable to see your next class, deadlines and directions.",
            message2: "You’ll review the courses, class times and any assessment data found in your import.",
            primaryTitle1: "Import timetable",
            primaryAction1: {},
            secondaryTitle: "Add a class manually",
            secondaryAction: {},
            secondaryTitle2: "Hello",
            secondaryAction2: {}
        )
        .padding(16)
    }
}
