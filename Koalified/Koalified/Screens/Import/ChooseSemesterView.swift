//
//  ChooseSemesterView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// "Which semester?": tick one or more semesters found in the file, then import them.
/// Matches the Figma frame "Import — choose semester".
struct ChooseSemesterView: View {
    let semesters: [DetectedSemester]
    let unplacedCount: Int
    let selected: Set<String>
    let statusFor: (DetectedSemester) -> String?
    let onToggle: (DetectedSemester) -> Void
    let onImport: () -> Void
    let onChooseDifferentFile: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            Text("Which semester?")
                .primaryTextStyling()
            Text("Your file has classes from \(plural(semesters.count, "semester"))")
                .secondaryTextStyling()

            Card {
                ForEach(semesters) { semester in
                    SemesterRow(
                        title: semester.title,
                        subtitle: "\(plural(semester.courseCount, "course")) · \(plural(semester.classCount, "class", "classes"))",
                        status: statusFor(semester),
                        isOn: selected.contains(semester.id)
                    ) { onToggle(semester) }
                    if semester.id != semesters.last?.id {
                        Divider()
                    }
                }
            }

            Text(note)
                .font(.fredoka(.caption))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            PrimaryButton(title: LocalizedStringKey("Import \(plural(selected.count, "semester"))"), action: onImport)
                .disabled(selected.isEmpty)
                .opacity(selected.isEmpty ? 0.4 : 1)
            SecondaryButton(title: "Choose a different file", action: onChooseDifferentFile)
        }
        .padding(.top, 8)
        .padding(.bottom, Layout.screenPadding)
    }

    private var note: String {
        var text = "Semesters are found from the class dates in your file. Import one or more."
        if unplacedCount > 0 {
            text += " \(plural(unplacedCount, "class", "classes")) without a semester can't be imported yet."
        }
        return text
    }
}

#Preview {
    ChooseSemesterView(
        semesters: [
            DetectedSemester(term: .S2, year: 2026, courseCount: 4, classCount: 11),
            DetectedSemester(term: .S1, year: 2026, courseCount: 4, classCount: 12)
        ],
        unplacedCount: 0,
        selected: ["S2-2026"],
        statusFor: { $0.term == .S2 ? "Current" : "Past" },
        onToggle: { _ in },
        onImport: {},
        onChooseDifferentFile: {}
    )
    .mainContainerStyling()
}
