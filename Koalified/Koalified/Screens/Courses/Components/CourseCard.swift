//
//  CourseCard.swift
//  Koalified
//

import SwiftUI

/// One course in the list, drawn as a folder in the course's colour: its next few assessments stick out the top
/// as papers, and the front shows the code, title and points earned out of 100.
/// Tapping the folder opens the course (`onView`); the chevron tucks the papers in or pulls them out.
struct CourseCard: View {
    let course: Course
    /// Opens the course's detail screen.
    var onView: () -> Void = {}

    @State private var isOpen = true

    /// How many papers stick out of the folder at most, so a long course doesn't make a tall card.
    private let maxPapers = 3
    private let paperColors: [Color] = [.tintMint, .tintAmber, .tintLavender]

    /// The next assessments still waiting for a mark (or the latest ones, once everything is marked),
    /// back to front: the one due soonest sits at the front.
    private var papers: [FolderPaper] {
        let byDue = course.assessments.sorted { $0.dueDate < $1.dueDate }
        let unmarked = byDue.filter { $0.mark == nil }
        let shown = unmarked.isEmpty ? Array(byDue.suffix(maxPapers)) : Array(unmarked.prefix(maxPapers))
        return shown.enumerated().map { index, item in
            FolderPaper(title: item.title,
                        kind: "\(item.weight.formatted(.number.precision(.fractionLength(0...1))))%",
                        color: paperColors[index % paperColors.count])
        }
        .reversed()
    }

    var body: some View {
        // Empty for a course that was just deleted (e.g. with its semester), so a stale card never reads it
        if course.isLive {
            folder
        }
    }

    @ViewBuilder
    private var folder: some View {
        let ink = course.color.onColor

        FolderCardBackground(color: course.color.color, ink: ink, papers: papers, isOpen: isOpen) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: course.courseCode)
                            .font(.fredoka(.largeTitle, .bold))
                        if let title = course.title, !title.isEmpty {
                            Text(verbatim: title)
                                .font(.fredoka(.subheadline))
                                .opacity(0.85)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    if !papers.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isOpen.toggle() }
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.headline.weight(.bold))
                                .rotationEffect(.degrees(isOpen ? 0 : 180))
                                .frame(width: 40, height: 40)
                                .background(ink.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isOpen ? Text("Hide assessments") : Text("Show assessments"))
                        .sensoryFeedback(.impact(weight: .light), trigger: isOpen)
                    }
                }

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(Int(course.earnedPoints.rounded()), format: .number)
                        .font(.fredoka(.title, .bold))
                    Text("/ 100 pts")
                        .font(.fredoka(.subheadline))

                    progressBar(ink: ink)
                        .padding(.horizontal, 10)

                    Text("\(course.assessments.count) cards")
                        .font(.fredoka(.subheadline))
                }
                .padding(.top, 6)
            }
        }
        // The whole folder opens the course; the chevron button above still gets its own taps.
        .contentShape(Rectangle())
        .onTapGesture(perform: onView)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text("View course"), onView)
    }

    /// Points earned out of 100 as a thin bar: a faint track in the folder's ink with the earned part solid.
    private func progressBar(ink: Color) -> some View {
        let fraction = min(max(course.earnedPoints / 100, 0), 1)

        return Capsule()
            .fill(ink.opacity(0.25))
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(ink)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)   // the points next to it already say the same thing
    }
}

/// A sample course whose three assessments are all still to come, for the preview.
private func previewCourse() -> Course {
    let course = Course(courseCode: "CSSE1001", title: "Introduction to Software Engineering",
                        term: .S2, year: 2026, color: .green)
    let soon = Date.now.addingTimeInterval(7 * 86_400)
    course.assessments = [
        AssessmentItem(title: "Assignment 1", weight: 20, dueDate: soon, mark: 80),
        AssessmentItem(title: "Programming project", weight: 30, dueDate: soon.addingTimeInterval(14 * 86_400)),
        AssessmentItem(title: "Final exam", weight: 50, dueDate: soon.addingTimeInterval(40 * 86_400)),
    ]
    return course
}

#Preview("Course cards") {
    ScrollView {
        VStack(spacing: 16) {
            CourseCard(course: previewCourse())
            CourseCard(course: Course(courseCode: "MATH1051", title: "Calculus & Linear Algebra I",
                                      term: .S2, year: 2026, color: .yellow))
        }
        .padding(16)
    }
    .background(Color.screenBackground)
}
