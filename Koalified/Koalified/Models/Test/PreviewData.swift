import SwiftData
import Foundation

/// Builds a date in 2026 from a day and month, for sample assessment due dates.
private func day(_ d: Int, _ m: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: 2026, month: m, day: d))!
}

/// In-memory SwiftData container pre-filled with sample courses and assessments, for previews.
@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let container = try! ModelContainer(
            for: Course.self, ClassSession.self, AssessmentItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let csse = Course(courseCode: "CSSE1001",
                          title: "Introduction to Software Engineering",
                          term: .semester2, year: 2026, color: .teal)
        let math = Course(courseCode: "MATH1051",
                          title: "Calculus & Linear Algebra I",
                          term: .semester2, year: 2026, color: .blue)
        context.insert(csse)
        context.insert(math)

        let items = [
            AssessmentItem(title: "Weekly labs", weight: 10, dueDate: day(16, 10), mark: 80, course: csse),
            AssessmentItem(title: "Assignment 1", weight: 20, dueDate: day(9, 10), mark: 60, course: csse),
            AssessmentItem(title: "Software project", weight: 30, dueDate: day(23, 10), course: csse),
            AssessmentItem(title: "Final exam", weight: 40, dueDate: day(6, 11), course: csse),
        ]
        items.forEach { context.insert($0) }

        return container
    }()
}
