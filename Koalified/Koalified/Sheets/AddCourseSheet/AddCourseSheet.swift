//
//  AddCourseSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

/// Sheet for adding a new course, or editing an existing one when `course` is passed in.
/// Collects the code, name, term, year and colour, validates them, then saves and refreshes the widget.
struct AddCourseSheet: View {

    @State private var term: Term = .S2
    @State private var year = 2026

    @State private var courseCode = ""
    @State private var courseName = ""

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var courses: [Course]

    @State private var showError = false
    @State private var errorMessage = ""

    /// The colour the user tapped; nil means they haven't chosen one.
    @State private var chosenColor: CourseColor?

    /// Colour used when none is chosen: cycles through the palette based on how many courses exist.
    private var autoColor: CourseColor {
        CourseColor.allCases[courses.count % CourseColor.allCases.count]
    }
    /// The chosen colour, or the automatic one.
    private var selectedColor: CourseColor { chosenColor ?? autoColor }

    /// The course being edited, or nil when adding a new one.
    var course: Course? = nil

    /// Called after a course is saved, just before the sheet closes, so the presenting view can show a confirmation.
    var onSaved: (() -> Void)? = nil

    /// Pre-fills the fields from `course` when editing.
    init(course: Course? = nil, onSaved: (() -> Void)? = nil) {
        self.course = course
        self.onSaved = onSaved
        _courseCode = State(initialValue: course?.courseCode ?? "")
        _courseName = State(initialValue: course?.title ?? "")
        _term = State(initialValue: course?.term ?? .S2)
        _year = State(initialValue: course?.year ?? 2026)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.screenPadding) {
            Text("Set up this course")
                .foregroundStyle(Color.textPrimary)
                .font(.fredoka(.largeTitle, .bold))
            
            Text("Enter assessment from your own course information")
                .foregroundStyle(.textSecondary)
                .font(.fredoka(.subheadline))
            
           
            CourseDetailsFields(code: $courseCode, name: $courseName)
            TermYearFields(term: $term, year: $year)
            ColorPickerRow(selection: $chosenColor, fallback: autoColor)
            
            Spacer()
            
            PrimaryButton(title: "Add course"){save()}
            
            
        }.padding(.top)
        .padding(.horizontal, Layout.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .PopUp(isPresented: $showError, message: LocalizedStringKey(errorMessage), image: "circle-x", colour: Color.redFill, feedback: .error)
    }
    
    /// Validates the form and then updates the existing course or inserts a new one.
    /// Shows an alert instead of saving if the code is empty or the course is a duplicate.
    private func save() {
        let cleanCode = courseCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        let cleanName = courseName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanCode.isEmpty else {
            errorMessage = "Enter a course code."
            showError = true
            return
        }

        // Same code, term and year as another course
        if courses.contains(where: { $0 !== course && $0.courseCode == cleanCode && $0.term == term && $0.year == year }) {
            errorMessage = "You already have \(cleanCode) in \(term.label), \(year)."
            showError = true
            return
        }

        if let course {
            course.courseCode = cleanCode
            course.title = cleanName.isEmpty ? nil : cleanName
            course.term = term
            course.year = year
        } else {
            modelContext.insert(Course(courseCode: cleanCode,
                                       title: cleanName.isEmpty ? nil : cleanName,
                                       term: term, year: year, color: selectedColor))
        }

        // Save now so the widget reloads with the change
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()

        onSaved?()
        dismiss()
    }
}


#Preview {
    AddCourseSheet()
}
