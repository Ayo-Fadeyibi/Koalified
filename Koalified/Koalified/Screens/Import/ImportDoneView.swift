//
//  ImportDoneView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// Shown after an import: how many classes were added, updated or left alone.
struct ImportDoneView: View {
    let result: ImportResult
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text("Timetable imported")
                .primaryTextStyling()
            Text(result.added + result.updated == 0
                 ? "Nothing changed. Your timetable was already up to date."
                 : "Your classes are ready.")
                .secondaryTextStyling()

            Card {
                ResultRow(label: "Added", value: result.added)
                Divider()
                ResultRow(label: "Updated", value: result.updated)
                Divider()
                ResultRow(label: "Unchanged", value: result.unchanged)
                if result.skipped > 0 {
                    Divider()
                    ResultRow(label: "Not imported (no semester)", value: result.skipped)
                }
            }

            Spacer()
            PrimaryButton(title: "Done", action: onDone)
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }
}

#Preview {
    ImportDoneView(result: ImportResult(added: 98, updated: 3, unchanged: 0, skipped: 0)) {}
        .mainContainerStyling()
}
