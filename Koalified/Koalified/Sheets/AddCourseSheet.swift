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
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.screenPadding) {
            Text("Set up this course")
                .foregroundStyle(Color.inkPrimary)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter assessment from your own course information")
                .foregroundStyle(.inkSecondary)
                .font(.subheadline)
            
            FormField("Course code"){}
            TextField("CSSE1001", text: $courseCode)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($focused, equals: .code)
                .padding(14)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(focused == .code ? Color.inkPop : Color.cardBorder,
                                      lineWidth: focused == .code ? 2 : 1)
                }
            
            FormField("Course name"){}
            TextField("Introduction to Software Engineering", text: $courseName)
                .focused($focused, equals: .name)
                .padding(14)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(focused == .name ? Color.inkPop : Color.cardBorder,
                                      lineWidth: focused == .name ? 2 : 1)
                }
            
            HStack(spacing: 12) {
                FormField("Semester") {
                    Picker("Semester", selection: $term) {
                        ForEach(Term.allCases, id: \.self) { term in
                            Text(term.label).tag(term)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Color.inkPrimary)
                }

                FormField("Year") {
                    Picker("Year", selection: $year) {
                        ForEach(2025...2028, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Color.inkPrimary)
                }
            }
            
            Spacer()
            
            PrimaryButton(title: "Add an assessment"){save()}
            SecondaryButton(title: "Copy a previous semester"){}
            
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
        let exists =    courses.contains { $0.courseCode == cleanCode && $0.term == term && $0.year == year }

        if exists {
            errorMessage = "You already have \(cleanCode) in \(term.label), \(year)."
            showError = true
            return
        }

        // 4. Pick the next colour
        let colour = CourseColor.allCases[courses.count % CourseColor.allCases.count]

        // 5. Create and insert
        let course = Course(courseCode: cleanCode,
                            title: cleanName.isEmpty ? nil : cleanName,
                            term: term, year: year, color: colour)
        modelContext.insert(course)

        // 6. Close the sheet
        dismiss()
    }
}


#Preview {
    AddCourseSheet()
}
