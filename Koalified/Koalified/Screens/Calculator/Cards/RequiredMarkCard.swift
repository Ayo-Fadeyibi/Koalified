//
//  RequiredMarkCard.swift
//  Koalified
//

import SwiftUI

/// "To reach a 6" card: the average needed on everything still to be marked, listed per assessment,
/// with a warning when the target (or the grade above it) can no longer be reached.
struct RequiredMarkCard: View {
    let course: Course
    let targetGrade: Int

    /// Assessments with no mark yet, soonest first.
    private var remaining: [AssessmentItem] {
        course.assessments.filter { $0.mark == nil }.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        let items = course.markInputs
        let rows = MarkCalculator.gradeDetailsRows(items: items)
        let target = rows.first { $0.grade == targetGrade }
        let remainingWeight = MarkCalculator.targetSummary(items: items, targetGrade: targetGrade).remainingWeight
        let needed = Int((target?.requiredPercent ?? 0).rounded(.up))
        let achieved = target?.achieved ?? false
        let obtainable = target?.obtainable ?? false
        // Mirrors the design: also warn when the next grade up is already out of reach.
        let nextOutOfReach = rows.first { $0.grade == targetGrade + 1 }.map { !$0.obtainable } ?? false

        Card {
            CardHeading("TO REACH A \(targetGrade)")

            // Headline
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                if achieved {
                    Text("Secured")
                        .font(.fredoka(.largeTitle, .bold))
                        .foregroundStyle(Color.accent)
                    Text("a \(targetGrade) is already banked")
                        .secondaryTextStyling()
                } else if obtainable {
                    Text(verbatim: "\(needed)%")
                        .font(.fredoka(.largeTitle, .bold))
                        .foregroundStyle(Color.accent)
                    Text("average on what's left")
                        .secondaryTextStyling()
                } else {
                    Text(verbatim: "–")
                        .font(.fredoka(.largeTitle, .bold))
                        .foregroundStyle(Color.textSecondary)
                    Text("can't be reached")
                        .secondaryTextStyling()
                }
            }

            // What's still to come, each needing the same average
            if obtainable && !achieved {
                CardDivider()

                if remaining.isEmpty {
                    row(title: Text("Everything left · \(remainingWeight)%"), value: "need \(needed)%")
                } else {
                    ForEach(remaining) { item in
                        row(title: Text(verbatim: "\(item.title) · \(item.weight.formatted(.number.precision(.fractionLength(0...2))))%"),
                            value: "need \(needed)%")
                    }
                }
            }

            if !obtainable || (!achieved && nextOutOfReach && targetGrade < 7) {
                CardDivider()
                Text("A \(obtainable ? targetGrade + 1 : targetGrade) is out of reach this semester.")
                    .font(.fredoka(.subheadline))
                    .foregroundStyle(Color.errorText)
            }
        }
    }

    private func row(title: Text, value: String) -> some View {
        HStack {
            title
                .font(.fredoka(.body))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Text(verbatim: value)
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.textPrimary)
        }
    }
}

#Preview {
    RequiredMarkCard(course: Course(courseCode: "CSSE1001", term: .S2, year: 2026, color: .teal), targetGrade: 6)
        .padding()
}
