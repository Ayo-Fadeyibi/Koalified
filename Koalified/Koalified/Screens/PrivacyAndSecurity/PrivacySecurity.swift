//
//  PrivacySecurity.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import SwiftUI

/// Privacy & security, pushed from the Profile tab: app lock and what shows while the phone is locked.
/// UI only for now; the toggles and lock delay are local state until they're wired up.
struct PrivacySecurity: View {

    @State private var isFaceIDLockOn = true
    @State private var lockDelay: LockDelay = .oneMinute
    @State private var hidesWidgetMarks = true
    @State private var hidesNotificationDetails = false
    @State private var blursInAppSwitcher = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy & security")
                .primaryTextStyling()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    appLockCard.appearAnimation(order: 0)
                    lockedPhoneCard.appearAnimation(order: 1)
                    onDeviceCard.appearAnimation(order: 2)
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .mainContainerStyling()
    }

    // MARK: - App lock

    private var appLockCard: some View {
        PlainCard {
            sectionLabel("App lock")

            SettingToggle(title: "Lock with Face ID",
                          message: "Or your phone passcode if Face ID fails.",
                          isOn: $isFaceIDLockOn)

            Divider()

            Text("Ask for it")
                .boldSecondaryTextStyling()

            HStack(spacing: 8) {
                ForEach(LockDelay.allCases) { delay in
                    DelayOption(title: delay.title, isSelected: lockDelay == delay) {
                        withAnimation(.easeInOut(duration: 0.15)) { lockDelay = delay }
                    }
                }
            }
            // The delay only matters while the lock is on
            .disabled(!isFaceIDLockOn)
            .opacity(isFaceIDLockOn ? 1 : 0.4)
        }
    }

    // MARK: - Locked phone

    private var lockedPhoneCard: some View {
        PlainCard {
            sectionLabel("When your phone is locked")

            SettingToggle(title: "Hide marks in widgets",
                          message: "Show \"3 assessments due\" instead of grades.",
                          isOn: $hidesWidgetMarks)

            Divider()

            SettingToggle(title: "Hide details in notifications",
                          message: "Reminders show the course code only.",
                          isOn: $hidesNotificationDetails)

            Divider()

            SettingToggle(title: "Blur app in app switcher",
                          message: "Hides your GPA when you swipe between apps.",
                          isOn: $blursInAppSwitcher)
        }
    }

    // MARK: - On device

    private var onDeviceCard: some View {
        PlainCard(bgColor: Color.tintAmber) {
            Text("Everything stays on this phone")
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Your report, GPA and marks are stored on your device and are not uploaded.")
                .secondaryTextStyling()
        }
    }

    /// Small all-caps heading at the top of a card, e.g. "APP LOCK".
    private func sectionLabel(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.fredoka(.caption, .semibold))
            .textCase(.uppercase)
            .kerning(0.5)
            .foregroundStyle(Color.textPrimary)
    }
}

/// How long the app can be in the background before Face ID is asked for again.
enum LockDelay: CaseIterable, Identifiable {
    case instantly, oneMinute, fiveMinutes

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .instantly: "Instantly"
        case .oneMinute: "After 1 min"
        case .fiveMinutes: "After 5 min"
        }
    }
}

/// A setting title with a short explanation underneath and a toggle on the right.
private struct SettingToggle: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn.animation(.easeInOut(duration: 0.2))) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(message)
                    .secondaryTextStyling()
            }
        }
    }
}

/// One choice in the "Ask for it" row: mint when selected, plain otherwise.
private struct DelayOption: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(isSelected ? Color.onMint : Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.mintFill : Color.cardSurface,
                            in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(Color.inkBorder, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        PrivacySecurity()
    }
}
