//
//  CoursesEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct CoursesEmptyView: View {
    let onAdd: () -> Void

    var body: some View {
        EmptyStateView(
            systemImage: "book",
            title: "No courses yet",
            message: "Add your courses to track marks and see what you need. Importing your timetable adds them for you.",
            primaryTitle: "Add a course",
            primaryAction: onAdd,
            secondaryTitle: "Import timetable",
            secondaryAction: { print("import timetable") }
        )
    }
}

#Preview {
    CoursesEmptyView(onAdd: {})
}
