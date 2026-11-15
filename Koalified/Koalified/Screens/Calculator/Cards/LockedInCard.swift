//
//  LockedInCard.swift
//  Koalified
//

import SwiftUI

/// "Locked in" card: the marks recorded so far, the points they've banked, and a way to edit them.
struct LockedInCard: View {
    let course: Course
    /// Called when the user taps "Edit recorded marks".
    let onEdit: () -> Void

    /// Assessments that already have a mark, oldest due date first.
    private var marked: [AssessmentItem] {
        course.assessments.filter { $0.mark != nil }.sorted { $0.dueDate < $1.dueDate }
    }

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }

    var body: some View {
        let banked = MarkCalculator.calculateTotalScore(course.markInputs)

        Card {
            CardHeading("LOCKED IN")

            if marked.isEmpty {
                Text("No marks recorded yet")
                    .secondaryTextStyling()
            } else {
                ForEach(marked) { item in
                    HStack {
                        Text(verbatim: "\(item.title) · \(format(item.weight))%")
                        Spacer()
                        Text(verbatim: "\(Int((item.mark ?? 0).rounded()))%")
                    }
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
                }
            }

            CardDivider()

            HStack {
                Text("Banked so far")
                    .font(.fredoka(.body))
                Spacer()
                Text("\(format(banked.score)) of \(format(banked.totalWeight * 100)) pts")
                    .font(.fredoka(.body, .bold))
            }
            .foregroundStyle(Color.textPrimary)

            SecondaryButton(title: "Edit recorded marks", action: onEdit)
        }
    }
}

#Preview {
    LockedInCard(course: Course(courseCode: "CSSE1001", term: .S2, year: 2026, color: .teal), onEdit: {})
        .padding()
}
