//
//  CalculatorContent.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// The Calculator tab when courses exist: pick a course, choose a target grade, see the average needed on
/// what's left, and review the marks already locked in.
struct CalculatorContent: View {
    @Query private var courses: [Course]

    /// Picker selection is a plain String key, not the Course itself: SwiftData models can change
    /// their hash (temporary -> permanent ID) while SwiftUI holds them as dictionary keys, which crashes.
    @State private var selectedCourseKey: String?
    @State private var selectedGrade = 5
    /// Set when the user taps "Edit recorded marks".
    @State private var editingCourse: Course?

    /// Stable, unique key for a course (code + term + year).
    private func key(for course: Course) -> String {
        "\(course.courseCode)-\(course.term.rawValue)-\(course.year)"
    }

    private var selectedCourse: Course? {
        courses.first { key(for: $0) == selectedCourseKey } ?? courses.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            coursePicker

            ScrollView {
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    if let course = selectedCourse {
                        TargetGradeCard(targetGrade: $selectedGrade)
                        RequiredMarkCard(course: course, targetGrade: selectedGrade)
                        LockedInCard(course: course) { editingCourse = course }
                    }

                    // Lets the last card scroll clear of the tab bar
                    Color.clear.frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationDestination(item: $editingCourse) { CourseDetailView(course: $0) }
    }

    /// Course dropdown (the shared `FloatingDropdown`), keyed by the stable course key.
    private var coursePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Course")
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(Color.textSecondary)

            FloatingDropdown(
                options: courses.map(key(for:)),
                selection: Binding(
                    get: { selectedCourse.map(key(for:)) ?? "" },
                    set: { selectedCourseKey = $0 }
                )
            ) { courseKey in
                courses.first { key(for: $0) == courseKey }?.courseCode ?? courseKey
            }
        }
        .zIndex(1)
    }
}

#Preview {
    NavigationStack {
        CalculatorContent()
            .padding(16)
    }
    .modelContainer(PreviewData.container)
}
