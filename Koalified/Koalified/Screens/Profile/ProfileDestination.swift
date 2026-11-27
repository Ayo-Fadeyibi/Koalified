//
//  ProfileDestination.swift
//  Koalified
//
//  Every screen the Profile tab can push. Rows link with `NavigationLink(value:)` and
//  `ProfileView` maps each value to its screen in one place.
//

import SwiftUI

/// Pushes the Profile screen itself. Value-based so it lands on the same navigation path as the
/// Profile rows; a view-based link would sit outside a path-bound stack and hide the rows' screens behind it.
struct ProfileRoot: Hashable {}

extension View {
    /// Registers the Profile screen. Apply inside each tab's NavigationStack.
    func profileDestination() -> some View {
        navigationDestination(for: ProfileRoot.self) { _ in ProfileView() }
    }
}

enum ProfileDestination: Hashable {
    case notifications, language, privacySecurity
    case addWidget, about, helpFeedback, comic
    case removeLink, deleteData
    case userDetails

    /// Row and screen title.
    var title: LocalizedStringKey {
        switch self {
        case .userDetails: "Your details"
        case .notifications: "Notifications"
        case .language: "Language"
        case .privacySecurity: "Privacy and Security"
        case .addWidget: "Add a widget"
        case .about: "About Koalified"
        case .helpFeedback: "Help & feedback"
        case .removeLink: "Remove timetable link"
        case .comic: "Comic"
        case .deleteData: "Delete semester data"
        }
    }
}

/// One tappable row in a Profile section: icon, title and a chevron.
struct ProfileRow: View {
    let destination: ProfileDestination

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {

                Text(destination.title)
                    .font(.fredoka(.body, .semibold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
               
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        Card {
            ProfileRow(destination: .notifications)
            ProfileRow(destination: .language)
        }
        .padding()
    }
}
