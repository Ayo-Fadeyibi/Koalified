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

    @FocusState private var isBuildingInputFocused: Bool
    @FocusState private var isRoomInputFocused: Bool

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
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .font(.fredoka(.body, .bold))
                    .padding()
                    .plainStyling()
                    .padding(.bottom, 24)
            }

            VStack(alignment: .leading) {

                Text("Time")
                    .boldSecondaryTextStyling()

                HStack {
                    DatePicker("Starts", selection: $start, displayedComponents: .hourAndMinute)
                        .font(.fredoka(.body, .bold))
                        .padding()
                        .plainStyling()

                    Spacer()

                    DatePicker("Ends", selection: $end, displayedComponents: .hourAndMinute)
                        .font(.fredoka(.body, .bold))
                        .padding()
                        .plainStyling()
                }.padding(.bottom, 24)
                    .zIndex(1)

                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Building")
                            .boldSecondaryTextStyling()

                        HStack(spacing: 10) {

                            TextField("Building, e.g. Priestley", text: $building)
                                .font(.fredoka(.body, .medium))
                                .foregroundStyle(Color.textPrimary)
                                .autocorrectionDisabled()
                                .submitLabel(.done)
                                .focused($isBuildingInputFocused)

                            if !building.isEmpty {
                                Button {
                                    building = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textSecondary)
                                }
                                .buttonStyle(.plain)
                            }

                        }.textFieldStyling(isFocused: isBuildingInputFocused)
                    }.padding(.bottom, 24)


                    VStack(alignment: .leading) {
                        Text("Room")
                            .boldSecondaryTextStyling()

                        HStack(spacing: 10) {

                            TextField("Room, e.g. 03-318", text: $room)
                                .font(.fredoka(.body, .medium))
                                .foregroundStyle(Color.textPrimary)
                                .autocorrectionDisabled()
                                .submitLabel(.done)
                                .focused($isRoomInputFocused)

                            if !room.isEmpty {
                                Button {
                                    room = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textSecondary)
                                }
                                .buttonStyle(.plain)
                            }

                        }.textFieldStyling(isFocused: isRoomInputFocused)
                    }.padding(.bottom, 24)

                }

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
