import SwiftUI

struct ClassForm: View {
    let currentSemesterCourses: [Course]
    @Binding var course: Course?
    @Binding var type: SessionType
    @Binding var start: Date
    @Binding var end: Date
    @Binding var building: String
    @Binding var room: String
    @Binding var weekday: Int
    @Binding var repeatsWeekly: Bool
    @Binding var date: Date
    let isValid: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {

                    Text("Course")
                        .boldSecondaryTextStyling()

                    FloatingDropdown(
                        options: [nil] + currentSemesterCourses.map { Optional($0) },
                        selection: $course
                    ) { course in
                        course?.courseCode ?? (currentSemesterCourses.isEmpty ? "No current courses" : "Choose a course")
                    }
                    .disabled(currentSemesterCourses.isEmpty)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Type")
                        .boldSecondaryTextStyling()

                    FloatingDropdown(options: SessionType.allCases.filter{$0 != .unknown},
                                     selection: $type
                    ) {
                        type in
                        type.localizedName
                    }
                }
            }.padding(.bottom, 24)
                .zIndex(3)

            Toggle("Repeats every week", isOn: $repeatsWeekly)
                .boldSecondaryTextStyling()
                .padding(.bottom, 24)

            if repeatsWeekly {
                VStack(alignment: .leading) {
                    Text("WeekDay")
                        .boldSecondaryTextStyling()

                    FloatingDropdown(
                        options: [2, 3, 4, 5, 6, 7, 1],
                        selection: $weekday
                    ) { day in
                        Calendar.current.weekdaySymbols[day - 1]
                    }
                }.padding(.bottom, 24)
                    .zIndex(2)
            } else {
                PopoverDatePicker(title: "Date", selection: $date)
                    .padding(.bottom, 24)
            }

            VStack(alignment: .leading) {

                Text("Time")
                    .boldSecondaryTextStyling()

                HStack {
                    PopoverDatePicker(title: "Starts", selection: $start, displayedComponents: .hourAndMinute)

                    Spacer()

                    PopoverDatePicker(title: "Ends", selection: $end, displayedComponents: .hourAndMinute)
                }.padding(.bottom, 24)
                    .zIndex(1)

                ClassLocationFields(building: $building, room: $room)

                if !isValid {
                    Text("End time must be after the start time.")
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.redFill)
                }

                Spacer()


                PrimaryButton(title: "Add Class", action: onSave)

            }

        }
    }
}
