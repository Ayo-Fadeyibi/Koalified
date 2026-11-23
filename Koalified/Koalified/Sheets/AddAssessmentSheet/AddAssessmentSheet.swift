
import SwiftUI
import SwiftData

/// Sheet for adding an assessment to a course.
struct AddAssessmentSheet: View {
    
    let onAdded: () -> Void
    
    var currentCourse: Course?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var courses: [Course]

    @State private var course: Course?
    @State private var name = ""
    @State private var weight: Double?
    @State private var dueDate = Date()
    @State private var hurdleExist = false
    @State private var hurdlePercent: Int?

    @State private var showError = false
    @State private var showCourseAdded = false
    @State private var errorMessage = ""
    
    @State private var openAddCourseSheet = false
    @State private var openImportSheet = false


    private var currentSemesterCourses: [Course] {
        guard let newest = courses.newestFirst.first else {
            return []
        }

        return courses.filter {
            $0.year == newest.year && $0.term == newest.term
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Add an assessment")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                TextButton(title: "Cancel") {
                    dismiss()
                }
            }
            .padding(.bottom, 28)

            // MARK: - Form
            if courses.isEmpty && currentCourse == nil {
                
                EmptyStateView(
                            title1: "No courses yet",
                            message1: "Add your courses to track marks and see what you need. Importing your timetable adds them for you.",
                            primaryTitle1: "Add a course",
                            primaryAction1: {openAddCourseSheet = true},
                            secondaryTitle: "Import timetable",
                            secondaryAction: { openImportSheet = true }
                        ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                

            } else {
                
                AssessmentForm(
                    currentCourse: currentCourse,
                    currentSemesterCourses: currentSemesterCourses,
                    course: $course,
                    name: $name,
                    weight: $weight,
                    dueDate: $dueDate,
                    hurdleExist: $hurdleExist,
                    hurdlePercent: $hurdlePercent
                )
                
            }

            Spacer(minLength: 24)

            // MARK: - Save
            if !courses.isEmpty || currentCourse != nil {
                PrimaryButton(
                    title: "Save assessment",
                    action: save
                )
            }
        }
        .padding(Layout.screenPadding)
        .containerStyling()
        .PopUp(
            isPresented: $showError,
            message: LocalizedStringKey(errorMessage),
            image: "circle-x",
            colour: Color.redFill,
            feedback: .error
        )
        .PopUp(
            isPresented: $showCourseAdded,
            message: "Course added successfully",
            image: "circle-check",
            colour: Color.mintFill,
            feedback: .success
        )
        .sheet(isPresented: $openImportSheet) {
            ImportLinkSheet()
                .sheetBorder()
        }
        .sheet(isPresented: $openAddCourseSheet) {
            AddCourseSheet(onSaved: {showCourseAdded = true})
                .sheetBorder()
        }
    }

    // MARK: - Validation

    private func fail(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func save() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            fail("Give the assessment a name.")
            return
        }

        guard let weight, weight > 0, weight <= 100 else {
            fail("Weight must be greater than 0 and at most 100.")
            return
        }

        guard let selectedCourse = currentCourse ?? course else {
            fail("Choose a course.")
            return
        }

        if hurdleExist {
            guard let hurdlePercent,
                  hurdlePercent > 0,
                  hurdlePercent <= 100 else {
                fail("Hurdle must be greater than 0 and at most 100.")
                return
            }
        }

        context.insert(
            AssessmentItem(
                title: cleanName,
                weight: weight,
                dueDate: dueDate,
                course: selectedCourse,
                hurdle: hurdleExist,
                hurdlePercent: hurdleExist ? hurdlePercent : nil
            )
        )

        Task {
            _ = await NotificationScheduler.requestPermission()
            AppSync.dataChanged(in: context)
        }

        onAdded()
        dismiss()
    }
}

#Preview {
    AddAssessmentSheet(onAdded: {})
        .modelContainer(PreviewData.container)
}
