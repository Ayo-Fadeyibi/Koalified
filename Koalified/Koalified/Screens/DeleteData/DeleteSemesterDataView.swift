//
//  DeleteSemesterDataView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI
import SwiftData

/// Delete semester data, pushed from the Profile tab. The student picks one semester and every course
/// in it is deleted; each course's classes and assessments (with their marks) go with it via the
/// cascade delete rule. Other semesters and the saved timetable link are left alone.
struct DeleteSemesterDataView: View {
    @Environment(\.modelContext) private var context
    @Query private var courses: [Course]

    @State private var selected: SemesterChoice?
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
            } else {
                Text("Choose a semester. Its courses, classes, assessments and marks will be deleted from this phone.")
                    .secondaryTextStyling()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(courses.semesterChoices, id: \.self) { semester in
                            SelectableRow(isSelected: selected == semester) {
                                withAnimation(.easeInOut(duration: 0.15)) { selected = semester }
                            } content: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(semester.label)
                                        .font(.fredoka(.body, .bold))
                                        .foregroundStyle(Color.textPrimary)

                                    Text(summary(of: semester))
                                        .font(.fredoka(.caption))
                                        .foregroundStyle(Color.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)

                deleteButton
            }
        }
        .padding(.bottom, 16)
        .mainContainerStyling()
        .confirmationDialog("Delete \(selected?.label ?? "")?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Delete semester", role: .destructive) { deleteSelected() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
        .PopUp(isPresented: $showDeleted, message: "Semester deleted", image: "circle-check", colour: Color.mintFill, feedback: .success)
    }

    /// Outlined with red text, matching Remove timetable link. Disabled until a semester is picked.
    private var deleteButton: some View {
        Button {
            showConfirm = true
        } label: {
            Text(selected.map { "Delete \($0.label)" } ?? "Choose a semester")
                .font(.fredoka(.body, .bold))
                .foregroundStyle(selected == nil ? Color.textSecondary : Color.redFill)
                .frame(maxWidth: .infinity)
                .padding()
                .plainStyling()
        }
        .buttonStyle(.plain)
        .disabled(selected == nil)
    }

    /// e.g. "4 courses · 12 classes · 9 assessments"
    private func summary(of semester: SemesterChoice) -> String {
        let inSemester = courses.filter(semester.contains)
        let classes = inSemester.reduce(0) { $0 + $1.sessions.count }
        let assessments = inSemester.reduce(0) { $0 + $1.assessments.count }
        return [
            count(inSemester.count, "course", "courses"),
            count(classes, "class", "classes"),
            count(assessments, "assessment", "assessments")
        ].joined(separator: " · ")
    }

    private func count(_ n: Int, _ one: String, _ many: String) -> String {
        "\(n) \(n == 1 ? one : many)"
    }

    private func deleteSelected() {
        guard let selected else { return }
        for course in courses where selected.contains(course) {
            context.delete(course)
        }
        // Saves, then rebuilds reminders and refreshes the widget without the deleted courses
        AppSync.dataChanged(in: context)
        self.selected = nil
        showDeleted = true
    }
}

#Preview {
    NavigationStack {
        DeleteSemesterDataView()
    }
    .modelContainer(PreviewData.container)
}
