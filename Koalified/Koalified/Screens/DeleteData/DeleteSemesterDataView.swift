//
//  DeleteSemesterDataView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI
import SwiftData

/// Delete semester data, pushed from the Profile tab. The student ticks one or more semesters and every
/// course in them is deleted; each course's classes and assessments (with their marks) go with it via the
/// cascade delete rule. Other semesters and the saved timetable link are left alone.
struct DeleteSemesterDataView: View {
    @Environment(\.modelContext) private var context
    // Animated so deleted semesters slide out instead of vanishing
    @Query(animation: .snappy) private var courses: [Course]

    @State private var selected: Set<SemesterChoice> = []
    @State private var showConfirm = false
    @State private var showDeleted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Delete semester data")
                .primaryTextStyling()

            if courses.isEmpty {
                PlainCard {
                    Text("Nothing to delete")
                        .font(.fredoka(.title3, .bold))
                        .foregroundStyle(Color.textPrimary)

                    Text("You don't have any courses saved yet.")
                        .secondaryTextStyling()
                }
                .appearAnimation()
            } else {
                Text("Choose the semesters to delete. Their courses, classes, assessments and marks will be removed from this phone.")
                    .secondaryTextStyling()

                ScrollView {
                    PlainCard {
                        let semesters = courses.semesterChoices
                        ForEach(semesters, id: \.self) { semester in
                            SemesterRow(title: semester.label,
                                        subtitle: summary(of: semester),
                                        status: nil,
                                        isOn: selected.contains(semester)) {
                                toggle(semester)
                            }
                            if semester != semesters.last {
                                Divider()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .appearAnimation(order: 0)
                }
                .scrollIndicators(.hidden)

                PrimaryButton(title: deleteTitle, action: { showConfirm = true }, bgColor: Color.redFill)
                    .disabled(selected.isEmpty)
                    .opacity(selected.isEmpty ? 0.4 : 1)
                    .appearAnimation(order: 1)
            }
        }
        .padding(.bottom, 16)
        .mainContainerStyling()
        .confirmationDialog(deleteTitle, isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteSelected() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
        .PopUp(isPresented: $showDeleted, message: "Semester data deleted", image: "circle-check", colour: Color.mintFill, feedback: .success)
    }

    /// "Delete Semester 2, 2026" for one semester, "Delete 2 semesters" for several.
    private var deleteTitle: LocalizedStringKey {
        if selected.count == 1, let only = selected.first {
            return "Delete \(only.label)"
        }
        return "Delete \(plural(selected.count, "semester"))"
    }

    private func toggle(_ semester: SemesterChoice) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selected.contains(semester) {
                selected.remove(semester)
            } else {
                selected.insert(semester)
            }
        }
    }

    /// e.g. "4 courses · 12 classes · 9 assessments"
    private func summary(of semester: SemesterChoice) -> String {
        let inSemester = courses.filter(semester.contains)
        let classes = inSemester.reduce(0) { $0 + $1.sessions.count }
        let assessments = inSemester.reduce(0) { $0 + $1.assessments.count }
        return [
            plural(inSemester.count, "course"),
            plural(classes, "class", "classes"),
            plural(assessments, "assessment")
        ].joined(separator: " · ")
    }

    private func deleteSelected() {
        for course in courses where selected.contains(where: { $0.contains(course) }) {
            context.delete(course)
        }
        // Saves, then rebuilds reminders and refreshes the widget without the deleted courses
        AppSync.dataChanged(in: context)
        selected = []
        showDeleted = true
    }
}

#Preview {
    NavigationStack {
        DeleteSemesterDataView()
    }
    .modelContainer(PreviewData.container)
}
