//
//  FoundInTimetableView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 3/11/2026.
//

import SwiftUI

/// One course found in the file, with how many classes it has.
struct FoundCourse {
    let code: String
    let title: String?
    let classCount: Int
}

/// "Found in your timetable": the courses about to be imported, so the student can check them
/// before the import runs. "Looks right" starts the import.
struct FoundInTimetableView: View {
    let courses: [FoundCourse]
    let onConfirm: () -> Void

    /// Card colours, repeated if there are more courses than colours.
    private let fills = [Color.tintMint, Color.tintPink, Color.tintAmber, Color.tintLavender]

    private var classTotal: Int {
        courses.reduce(0) { $0 + $1.classCount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Found in your timetable")
                    .font(.fredoka(.largeTitle, .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("\(plural(courses.count, "course")), \(plural(classTotal, "class", "classes")). Check it looks right.")
                    .secondaryTextStyling()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(courses.enumerated()), id: \.offset) { index, course in
                        courseCard(course, fill: fills[index % fills.count])
                    }
                }
            }
            .scrollIndicators(.hidden)

            Button(action: onConfirm) {
                Text("Looks right")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.onMint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: 30)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 24)
        .padding(.bottom, Layout.screenPadding)
    }

    private func courseCard(_ course: FoundCourse, fill: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.code)
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)
            if let title = course.title {
                Text(title)
                    .font(.fredoka(.subheadline))
                    .foregroundStyle(Color.textPrimary.opacity(0.7))
            }
            Text(plural(course.classCount, "class", "classes"))
                .font(.fredoka(.footnote, .bold))
                .foregroundStyle(Color.accent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .neoBrutalist(backgroundColor: fill, cornerRadius: Layout.radiusCard)
    }
}

#Preview {
    FoundInTimetableView(
        courses: [
            FoundCourse(code: "CSSE1001", title: "Introduction to Software Engineering", classCount: 3),
            FoundCourse(code: "MATH1051", title: "Calculus and Linear Algebra I", classCount: 3),
            FoundCourse(code: "ECON1010", title: "Introduction to Economics", classCount: 3),
            FoundCourse(code: "ENGG1100", title: "Professional Engineering", classCount: 2)
        ],
        onConfirm: {}
    )
    .mainContainerStyling()
}
