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
       
        VStack {
            EmptyStateView(
                header1: "A LITTLE BREATHING ROOM",
                title1: "No classes today.",
                message1: "A free day for a study session, catching up or taking a break.",
                primaryTitle1: "See your week",
                primaryAction1: onSeeWeek,
            ).padding(.bottom, 10)
            
            ScrollView {
                UpcomingAssessments()
            }.scrollIndicators(.hidden)
        }.containerStyling()
    
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
