//
//  NoClassView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

import SwiftData

struct NoClassView: View {
    
    let onSeeWeek: () -> Void
    let onViewAssessment: () -> Void
    
    @Query private var assessments: [AssessmentItem]
    
    let now: Date
    
    var body: some View {
        let next = nextAssessment(from: assessments, now: now)
        
        EmptyStateView(
            header1: "A LITTLE BREATHING ROOM",
            header2: (next?.course?.courseCode).map { LocalizedStringKey($0) },
            title1: "No classes today.",
            title2: next.map { LocalizedStringKey($0.title) },
            message1: "A free day for a study session, catching up or taking a break.",
            message2: next.map{LocalizedStringKey("\(dueLabel(for: $0.dueDate, now: now)) · \($0.weight.formatted())% of course grade")},
            primaryTitle1: "See your week",
            primaryAction1: onSeeWeek,
            secondaryTitle2: next != nil ? "View Assessment" : nil,
            secondaryAction2: onViewAssessment
            
            
        ).containerStyling()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Course.self, AssessmentItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let course = Course(courseCode: "CSSE1001", title: "Introduction to Software Engineering",
                        term: .S2, year: 2026, color: .teal)
    container.mainContext.insert(course)

    let quiz = AssessmentItem(title: "Quiz 1", weight: 15,
                              dueDate: .now.addingTimeInterval(3 * 86_400), course: course)
    container.mainContext.insert(quiz)

    return NoClassView(onSeeWeek: {}, onViewAssessment: {}, now: .now)
        .modelContainer(container)
        .padding(16)
}
