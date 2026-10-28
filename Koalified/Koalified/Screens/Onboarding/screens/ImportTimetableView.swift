//
//  ImportTimetableView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// Final onboarding screen: a field to paste the timetable link and an Import button.
/// (The import itself is not implemented yet; the button just finishes onboarding.)
struct ImportTimetableView: View {
    /// Called when the user taps Import.
    let onDone: () -> Void
    /// The pasted timetable link.
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import your timetable")
                .primaryTextStyling()

            TextField("Paste your timetable link", text: $link)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .boxStyling(bgColor: Color.white, cRadius: Layout.radiusSmall, sColor: Color.cardBorder, lWidth: 1)

            Spacer()

            PrimaryButton(title: "Import", action: onDone)
        }
        .mainContainerStyling()
    }
}

#Preview {
    ImportTimetableView(onDone: {})
}
