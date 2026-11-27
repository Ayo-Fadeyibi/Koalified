//
//  AssessmentWidget.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import WidgetKit
import SwiftUI

/// Cream fill with a 2pt black border drawn cleanly inside the widget's corner radius.
private struct AssessmentWidgetBackground: View {
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.widgetCream)
            ContainerRelativeShape().strokeBorder(Color.inkBorder, lineWidth: 2)
        }
    }
}

/// Neo-Brutalist pill badge matching the main app.
private struct AssessmentPill<Content: View>: View {
    let fill: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(fill)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))
    }
}

struct AssessmentWidgetView: View {
    let entry: AssessmentEntry
    @Environment(\.widgetFamily) private var family

    /// Rows listed under the hero card in the large widget.
    private let maxLargeRows = 3

    var body: some View {
        if let next = entry.next {
            switch family {
            case .systemLarge: largeView(next)
            default: mediumView(next)
            }
        } else {
            emptyStateView
        }
    }

    // MARK: - Medium
    private func mediumView(_ next: AssessmentSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            statusRow(for: next)

            Spacer(minLength: 8)

            heroRow(for: next)

            Spacer(minLength: 8)

            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Large
    private func largeView(_ next: AssessmentSnapshot) -> some View {
        let later = Array(entry.upcoming.dropFirst())
        let rows = later.prefix(maxLargeRows)
        let hiddenCount = later.count - rows.count

        return VStack(alignment: .leading, spacing: 8) {
            header

            // Hero card for the next assessment
            VStack(alignment: .leading, spacing: 10) {
                statusRow(for: next)
                heroRow(for: next)
            }
            .padding(12)
            .background(Color.widgetRowWhite)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.inkBorder, lineWidth: 2))
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.inkBorder)
                    .offset(x: 2.5, y: 2.5)
            )

            if rows.isEmpty {
                Spacer(minLength: 4)
                Text("Nothing else coming up.")
                    .font(fredoka(14, .medium))
                    .foregroundStyle(Color.textSecondary)
                Spacer(minLength: 4)
            } else {
                Text("AFTER THAT")
                    .font(fredoka(12, .bold))
                    .foregroundStyle(Color.textSecondary)

                VStack(spacing: 8) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, assessment in
                        row(assessment)
                    }
                }

                Spacer(minLength: 2)

                if hiddenCount > 0 {
                    Text(verbatim: "+\(hiddenCount) more")
                        .font(fredoka(12, .bold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Header ("UPCOMING ASSESSMENTS" + "FRI 27 NOV")
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("UPCOMING ASSESSMENTS")
                .font(fredoka(13, .bold))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(entry.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                .font(fredoka(12, .bold))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Status Pill + Course Code Pill
    private func statusRow(for next: AssessmentSnapshot) -> some View {
        HStack(spacing: 8) {
            AssessmentPill(fill: isUrgent(next) ? Color.widgetAmber : Color.widgetMint) {
                statusHeader(for: next)
                    .font(fredoka(11, .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            AssessmentPill(fill: Color.widgetCream) {
                Text(verbatim: next.courseCode)
                    .font(fredoka(12, .bold))
                    .foregroundStyle(Color.textPrimary)
            }
        }
    }

    // MARK: - Framed Weight Tile + Title & Due Date
    private func heroRow(for next: AssessmentSnapshot) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(verbatim: weightText(next.weight))
                .font(fredoka(26, .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isUrgent(next) ? Color.widgetAmber : Color.widgetCream)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.inkBorder, lineWidth: 2)
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.inkBorder)
                        .offset(x: 3, y: 3)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: next.title)
                    .font(fredoka(15, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text("Due \(dueText(next.dueDate))")
                    .font(fredoka(13, .medium))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Bottom Action Footer
    private var footer: some View {
        HStack {
            Text("Open assessments")
                .font(fredoka(13, .semibold))
                .foregroundStyle(Color.greenDeep)

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(5)
                .background(Color.widgetAmber)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.inkBorder, lineWidth: 1.5))
        }
    }

    // MARK: - Later Assessment Row (large)
    private func row(_ assessment: AssessmentSnapshot) -> some View {
        let due = dueText(assessment.dueDate)

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: assessment.courseCode)
                    .font(fredoka(15, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(verbatim: "\(assessment.title) · \(due)")
                    .font(fredoka(12, .medium))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(verbatim: weightText(assessment.weight))
                .font(fredoka(11, .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.widgetMint)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.widgetRowWhite)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.inkBorder, lineWidth: 2))
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.inkBorder)
                .offset(x: 2.5, y: 2.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(assessment.courseCode) \(assessment.title), worth \(weightText(assessment.weight)), due \(due)")
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 0) {
            AssessmentPill(fill: Color.widgetMint) {
                Text("ALL CAUGHT UP")
                    .font(fredoka(11, .bold))
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer(minLength: 8)

            Text("Nothing due.")
                .font(fredoka(24, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("No upcoming assessments. Enjoy the quiet.")
                .font(fredoka(14, .regular))
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 2)

            Spacer(minLength: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Helpers
    @ViewBuilder
    private func statusHeader(for next: AssessmentSnapshot) -> some View {
        if next.dueDate <= entry.date {
            Text("DUE NOW")
        } else {
            Text("DUE · \(next.dueDate, style: .relative)")
        }
    }

    /// Due now, or within the next 24 hours.
    private func isUrgent(_ assessment: AssessmentSnapshot) -> Bool {
        assessment.dueDate.timeIntervalSince(entry.date) < 86400
    }

    /// "15%" or "7.5%"
    private func weightText(_ weight: Double) -> String {
        "\(weight.formatted(.number.precision(.fractionLength(0...1))))%"
    }

    /// "Fri 4 Dec, 11:59 pm"
    private func dueText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())
    }
}

struct AssessmentWidget: Widget {
    let kind = "AssessmentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AssessmentProvider()) { entry in
            AssessmentWidgetView(entry: entry)
                .containerBackground(for: .widget) { AssessmentWidgetBackground() }
        }
        .configurationDisplayName("Upcoming Assessments")
        .description("See your next assessment's course, title and a live countdown to its due date.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Preview
private let previewAssessments = [
    AssessmentSnapshot(courseCode: "COMP3400", dueDate: .now.addingTimeInterval(5 * 3600), title: "Assignment 1", weight: 15),
    AssessmentSnapshot(courseCode: "MATH1051", dueDate: .now.addingTimeInterval(2 * 86400), title: "Quiz 2", weight: 5),
    AssessmentSnapshot(courseCode: "DECO1800", dueDate: .now.addingTimeInterval(4 * 86400), title: "Design Report", weight: 30),
    AssessmentSnapshot(courseCode: "COMP3506", dueDate: .now.addingTimeInterval(6 * 86400), title: "Problem Set 3", weight: 7.5),
    AssessmentSnapshot(courseCode: "CSSE2310", dueDate: .now.addingTimeInterval(8 * 86400), title: "Practical Exam", weight: 20),
    AssessmentSnapshot(courseCode: "STAT2003", dueDate: .now.addingTimeInterval(12 * 86400), title: "Final Exam", weight: 50)
]

#Preview(as: .systemMedium) {
    AssessmentWidget()
} timeline: {
    AssessmentEntry(date: .now, upcoming: Array(previewAssessments.dropFirst()))
    AssessmentEntry(date: .now, upcoming: previewAssessments)
    AssessmentEntry(date: .now, upcoming: [])
}

#Preview(as: .systemLarge) {
    AssessmentWidget()
} timeline: {
    AssessmentEntry(date: .now, upcoming: previewAssessments)
    AssessmentEntry(date: .now, upcoming: Array(previewAssessments.prefix(1)))
    AssessmentEntry(date: .now, upcoming: [])
}
