//
//  AboutKoalifiedView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

/// About Koalified, pushed from the Profile tab: what the app is, what each tab does,
/// how data is kept, and the app version.
struct AboutKoalifiedView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About Koalified")
                .primaryTextStyling()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    introCard
                    featuresSection
                    privacyCard
                    footer
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .mainContainerStyling()
    }

    // MARK: - Intro

    private var introCard: some View {
        PlainCard {
            Image("comic_03_hero")
                .resizable()
                .scaledToFill()
                // The artwork is empty along the bottom, so show it from the top
                .frame(maxWidth: .infinity, maxHeight: 280, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .accessibilityHidden(true)

            Text("Your semester, sorted.")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Koalified brings your UQ timetable, assessments and marks together in one place, so you always know what's next.")
                .secondaryTextStyling()
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's inside")
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)

            PlainCard {
                ForEach(Feature.all) { feature in
                    FeatureRow(feature: feature)
                }
            }
        }
    }

    // MARK: - Privacy

    private var privacyCard: some View {
        PlainCard {
            Text("Private by design")
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Everything stays on this phone. There's no account to make, nothing is synced to iCloud, and your timetable link is kept in the Keychain.")
                .secondaryTextStyling()
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 4) {
            Text("Koalified \(appVersion)")
                .boldSecondaryTextStyling()

            Text("Made for UQ students. Not affiliated with The University of Queensland.")
                .font(.fredoka(.caption))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    /// e.g. "1.0 (12)", read from the app bundle.
    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}

/// One part of the app, shown with the same icon as its tab.
private struct Feature: Identifiable {
    let id: Int
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    static let all = [
        Feature(id: 0, icon: "house", title: "Today",
                detail: "Your next class, upcoming assessments and important dates at a glance."),
        Feature(id: 1, icon: "calendar-range", title: "Timetable",
                detail: "Your week of classes, imported straight from UQ."),
        Feature(id: 2, icon: "book-open", title: "Courses",
                detail: "Every course with its classes, assessments and marks."),
        Feature(id: 3, icon: "calculator", title: "Calculator",
                detail: "Work out the marks you need to hit your target grade."),
        Feature(id: 4, icon: "sparkles", title: "Widgets",
                detail: "See today's schedule and your next class from the Home Screen.")
    ]
}

private struct FeatureRow: View {
    let feature: Feature

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(feature.icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.textPrimary)
                .frame(width: 36, height: 36)
                .background(Color.mintFill.opacity(0.4), in: RoundedRectangle(cornerRadius: Layout.radiusSmall - 4))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(feature.detail)
                    .secondaryTextStyling()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        AboutKoalifiedView()
    }
}
