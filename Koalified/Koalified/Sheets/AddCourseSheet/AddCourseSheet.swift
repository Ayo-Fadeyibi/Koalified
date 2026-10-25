//
//  AddCourseSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI
import SwiftData

struct AddCourseSheet: View {

    @State private var term: Term = .semester2
    @State private var year = 2026
    
    @State private var courseCode = ""
    @State private var courseName = ""
    
    enum Field { case code, name }
    @FocusState private var focused: Field?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var courses: [Course]
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var chosenColor: CourseColor?

    private var autoColor: CourseColor {
        CourseColor.allCases[courses.count % CourseColor.allCases.count]
    }
    private var selectedColor: CourseColor { chosenColor ?? autoColor }
    
    var course: Course? = nil
    
    init(course: Course? = nil) {
        self.course = course
        _courseCode = State(initialValue: course?.courseCode ?? "")
        _courseName = State(initialValue: course?.title ?? "")
        _term = State(initialValue: course?.term ?? .semester2)
        _year = State(initialValue: course?.year ?? 2026)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.screenPadding) {
            Text("Set up this course")
                .foregroundStyle(Color.inkPrimary)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter assessment from your own course information")
                .foregroundStyle(.inkSecondary)
                .font(.subheadline)
            
           
            CourseDetailsFields(code: $courseCode, name: $courseName)
            TermYearFields(term: $term, year: $year)
            ColorPickerRow(selection: $chosenColor, fallback: autoColor)
            
            Spacer()
            
            PrimaryButton(title: "Add course"){save()}
            
            Text("Enter assessment names, weights and dates yourself. No automatic lookup or course-profile extraction")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            
        }.padding(.top)
        .padding(.horizontal, Layout.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.canvas)
            .alert("Can't add course", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
    }
    
    private func save() {
        // 1. Clean the text
        let cleanCode = courseCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        let cleanName = courseName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Validate: a course needs a code
        guard !cleanCode.isEmpty else {
            errorMessage = "Enter a course code."
            showError = true
            return
        }
        
        // 3. Duplicate check: same code, term and year
        let exists =    courses.contains { $0 !== course && $0.courseCode == cleanCode && $0.term == term && $0.year == year }

        if exists {
            errorMessage = "You already have \(cleanCode) in \(term.label), \(year)."
            showError = true
            return
        }

        // 4. Pick the next colour
        let colour = selectedColor
        // 5. Create and insert
        if let course {
            course.courseCode = cleanCode
               course.title = cleanName.isEmpty ? nil : cleanName
               course.term = term
               course.year = year
        } else {
            modelContext.insert(Course(courseCode: cleanCode,
                                       title: cleanName.isEmpty ? nil : cleanName,
                                       term: term, year: year, color: colour))
        }
       

        // 6. Close the sheet
        dismiss()
    }
}


#Preview {
    AddCourseSheet()
}
