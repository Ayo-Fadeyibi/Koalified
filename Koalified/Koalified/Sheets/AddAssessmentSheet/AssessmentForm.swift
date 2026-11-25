import SwiftUI

struct AssessmentForm: View {
    let currentCourse: Course?
    let currentSemesterCourses: [Course]
    @Binding var course: Course?
    @Binding var name: String
    @Binding var weight: Double?
    @Binding var dueDate: Date
    @Binding var hurdleExist: Bool
    @Binding var hurdlePercent: Int?

    @FocusState private var isNameFocused: Bool
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isHurdleFocused: Bool

    private let fieldSpacing: CGFloat = 8
    private let sectionSpacing: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {

            // Course
            if currentCourse == nil {
                VStack(alignment: .leading, spacing: fieldSpacing) {
                    Text("Course")
                        .boldSecondaryTextStyling()

                    FloatingDropdown(
                        options: [nil] + currentSemesterCourses.map { Optional($0) },
                        selection: $course
                    ) { selectedCourse in
                        selectedCourse?.courseCode
                            ?? (currentSemesterCourses.isEmpty
                                ? "No current courses"
                                : "Choose a course")
                    }
                    .disabled(currentSemesterCourses.isEmpty)
                }
                .zIndex(3)
            }

            // Name
            VStack(alignment: .leading, spacing: fieldSpacing) {
                Text("Name")
                    .boldSecondaryTextStyling()

                HStack(spacing: 10) {
                    TextField("e.g. Quiz 1", text: $name)
                        .focused($isNameFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            isWeightFocused = true
                        }

                    if !name.isEmpty {
                        ClearFieldButton {
                            name = ""
                        }
                    }
                }
                .textFieldStyling(isFocused: isNameFocused)
            }

            // Weight and due date
            HStack(alignment: .top, spacing: 12) {

                VStack(alignment: .leading, spacing: fieldSpacing) {
                    Text("Weight (%)")
                        .boldSecondaryTextStyling()

                    HStack(spacing: 10) {
                        TextField(
                            "e.g. 20",
                            value: $weight,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .focused($isWeightFocused)

                        if weight != nil {
                            ClearFieldButton {
                                weight = nil
                            }
                        }
                    }
                    .textFieldStyling(isFocused: isWeightFocused)
                }
                .frame(maxWidth: .infinity, alignment: .leading)


                VStack(alignment: .leading, spacing: fieldSpacing) {
                    Text("Due date")
                        .boldSecondaryTextStyling()

                    DatePicker(
                        "Due date",
                        selection: $dueDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .padding(7)
                    .plainStyling()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - Hurdle
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $hurdleExist.animation(.easeInOut(duration: 0.2))) {
                    Text("Hurdle")
                        .boldSecondaryTextStyling()
                }

                if hurdleExist {
                    VStack(alignment: .leading, spacing: fieldSpacing) {
                        Text("Minimum required (%)")
                            .boldSecondaryTextStyling()

                        HStack(spacing: 10) {
                            TextField(
                                "e.g. 50",
                                value: $hurdlePercent,
                                format: .number
                            )
                            .keyboardType(.numberPad)
                            .focused($isHurdleFocused)

                            if hurdlePercent != nil {
                                ClearFieldButton {
                                    hurdlePercent = nil
                                }
                            }
                        }
                        .textFieldStyling(isFocused: isHurdleFocused)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }


}
