import SwiftUI

/// One semester's header ("Semester 1, 2026 — 3 courses") followed by its course cards.
struct SemesterSectionView: View {
    let section: SemesterSection
    @Binding var path: NavigationPath

    var body: some View {
        HStack {
            Text(section.title)
                .font(.fredoka(.headline))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Text("\(section.courses.count) courses")
                .font(.fredoka(.footnote))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.top, 4)

        ForEach(section.courses) { course in
            CourseCard(
                code: course.courseCode,
                title: course.title ?? "",
                accent: course.color.color,
                earned: course.earnedPoints,
                course: course,
                onView: { path.append(course) }
            )
        }
    }
}
