//
//  NoClassesFoundView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// Shown when the chosen file has no readable classes.
/// Matches the Figma frame "Import — no classes found".
struct NoClassesFoundView: View {
    let onChooseDifferentFile: () -> Void
    let onAddManually: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text("No classes found")
                .primaryTextStyling()
            Text("We couldn't read any classes from this file")
                .secondaryTextStyling()

            Card {
                HelpRow(title: "Check the file type",
                        text: "Use the .ics calendar file you downloaded from your timetable, not a screenshot or PDF.")
                Divider()
                HelpRow(title: "Check the export",
                        text: "Export your timetable again and make sure it includes your classes before importing.")
            }

            PrivacyNote()

            Spacer()

            PrimaryButton(title: "Choose a different file", action: onChooseDifferentFile)
            SecondaryButton(title: "Add classes manually", action: onAddManually)
        }
        .padding(.top, 8)
        .padding(.bottom, Layout.screenPadding)
    }
}

#Preview {
    NoClassesFoundView(onChooseDifferentFile: {}, onAddManually: {})
        .mainContainerStyling()
}
