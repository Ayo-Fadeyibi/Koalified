//
//  CalculatorContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 28/10/2026.
//

import SwiftUI
import SwiftData

struct CalculatorContent: View {
    @Query private var courses: [Course]
    /// Picker selection is a plain String key, not the Course itself: SwiftData models can change
    /// their hash (temporary -> permanent ID) while SwiftUI holds them as dictionary keys, which crashes.
    @State private var selectedCourseKey: String?
    @State private var selectedGrade: Int? = nil

    /// Stable, unique key for a course (code + term + year).
    private func key(for course: Course) -> String {
        "\(course.courseCode)-\(course.term.rawValue)-\(course.year)"
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: Layout.sectionSpacing) {
            Text("Calculator")
                .primaryTextStyling()
            
            FormField("Course") {
                Picker("Course", selection: $selectedCourseKey) {
                    ForEach(courses) { course in
                        Text(course.courseCode).tag(Optional(key(for: course)))
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(Color.inkPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ScrollView (.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(GradeData.grades, id: \.self) { grade in
                        Button {
                            selectedGrade = grade
                        } label: {
                            Text("Grade \(grade)")
                                .font(.subheadline)
                                .foregroundStyle(Color.inkPop)
                                .fontWeight(.bold)
                                .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: grade == selectedGrade ? Color.inkPop : Color.cardBorder, lWidth: grade == selectedGrade ? 2 : 1)

                        }
                    }
                }
            }.fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            VStack {
                PrimaryButton(title: "Try different marks") {}
                SecondaryButton(title: "Share exam target") {}
            }
            .padding(.bottom, 16)
            
        }
        .mainContainerStyling()
    }
}


#Preview {
    CalculatorContent()
        .modelContainer(PreviewData.container)
}
