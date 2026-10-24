//
//  PreviewData.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftData
import Foundation

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

        let quiz = AssessmentItem(title: "Quiz 1", weight: 20,
                                  dueDate: .now, mark: 100)
        context.insert(quiz)
        csse.assessments.append(quiz)

        return container
    }()
}
