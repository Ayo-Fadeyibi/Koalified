//
//  StartImportView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// First import screen: explains what to pick and opens the file picker.
struct StartImportView: View {
    let errorMessage: String?
    let onChooseFile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text("Import your timetable")
                .primaryTextStyling()
            Text("Choose the .ics calendar file you downloaded from your timetable.")
                .secondaryTextStyling()
            if let errorMessage {
                Text(errorMessage)
                    .font(.fredoka(.footnote, .semibold))
                    .foregroundStyle(Color.roseFill)
            }
            Spacer()
            PrivacyNote()
            PrimaryButton(title: "Choose .ics file", action: onChooseFile)
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }
}

#Preview {
    StartImportView(errorMessage: nil) {}
        .mainContainerStyling()
}
