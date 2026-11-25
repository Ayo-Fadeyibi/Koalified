//
//  AssessmentList.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 26/11/2026.
//

import SwiftUI
import SwiftData

struct UpcomingAssessments: View {
    
    @Query(sort: \AssessmentItem.dueDate) private var assessments: [AssessmentItem]
    
    private var dueAssessments: [AssessmentItem] {
        return assessments.filter {
            $0.dueDate >= .now
        }
    }
    
    var body: some View {
        // Hidden when nothing is still to come. No scroll view of its own: the Today screen scrolls it
        // together with the rest of the day's classes.
        if !dueAssessments.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("UPCOMING ASSESSMENTS")
                    .font(.fredoka(.caption, .bold))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 4)

                ForEach(dueAssessments.prefix(5)) { item in
                    // The wallet's ticket, closed (no stub), so it reads as a card rather than something to act on.
                    AssessmentCard(
                        courseCode: item.course?.courseCode ?? "",
                        courseColor: item.course?.color.color ?? Color.cardSurface,
                        onCourseColor: item.course?.color.onColor ?? Color.textPrimary,
                        assessmentTitle: item.title,
                        weight: item.weight,
                        dueDate: item.dueDate,
                        hasHurdle: item.hurdle ?? false,
                        hurdlePercent: item.hurdlePercent,
                        openCard: false,
                        isDone: item.isDone,
                        compact: true
                    )
                }
            }
        }
        
    }
}

#Preview {
    ScrollView {
        UpcomingAssessments()
            .padding()
    }
    .background(Color.screenBackground)
    .modelContainer(PreviewData.container)
}

#Preview("Compact card") {
    // The sample assessments are all past due, so this shows the compact card on its own.
    VStack(spacing: 10) {
        AssessmentCard(courseCode: "CSSE3200", courseColor: CourseColor.teal.color, onCourseColor: CourseColor.teal.onColor,
                       assessmentTitle: "Quiz 1", weight: 10, dueDate: .now.addingTimeInterval(3 * 86_400),
                       hasHurdle: true, hurdlePercent: 20, openCard: false, compact: true)
        AssessmentCard(courseCode: "MATH1051", courseColor: CourseColor.blue.color, onCourseColor: CourseColor.blue.onColor,
                       assessmentTitle: "Assignment 2", weight: 25, dueDate: .now.addingTimeInterval(9 * 86_400),
                       hasHurdle: false, hurdlePercent: nil, openCard: false, compact: true)
        AssessmentCard(courseCode: "CSSE3200", courseColor: CourseColor.teal.color, onCourseColor: CourseColor.teal.onColor,
                       assessmentTitle: "Quiz 1 (TEMP full size)", weight: 10, dueDate: .now.addingTimeInterval(3 * 86_400),
                       hasHurdle: true, hurdlePercent: 20, openCard: false)
    }
    .padding()
    .background(Color.screenBackground)
}
