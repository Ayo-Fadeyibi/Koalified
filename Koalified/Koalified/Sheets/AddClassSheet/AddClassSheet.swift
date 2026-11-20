//
//  AddClasses.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddClassSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @Query private var existingSessions: [ClassSession]

    @State private var course: Course?
    @State private var type: SessionType = .LEC
    // Default to 9:00-10:00 so the form is valid whatever time the sheet is opened
    @State private var start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    @State private var end = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now) ?? .now.addingTimeInterval(3600)
    @State private var building = ""
    @State private var room = ""
    @State private var weekday = 2   // 1 = Sunday ... 7 = Saturday, so 2 = Monday
    @State private var repeatsWeekly = true
    @State private var date = Date.now
    
    private var isValid: Bool { timesAreValid(from: start, to: end) }
    private var canSave: Bool { Koalified.canSave(course: course, valid: isValid) }
    
    let onAdded: () -> Void
    
    @State private var showNoDatesMessage = false
    @State private var pendingTimes: [(start: Date, end: Date)] = []
    @State private var showClashAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add class")
                .primaryTextStyling()
                .padding(.bottom, 20)
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("Course")
                        .boldSecondaryTextStyling()
                    
                    FloatingDropdown(
                        options: [nil] + courses.map { Optional($0) },
                        selection: $course
                    ) { course in
                        course?.courseCode ?? "Choose a course"
                    }
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
            }.padding(.bottom, 10)
                .zIndex(3)
            
            Toggle("Repeats every week", isOn: $repeatsWeekly)
                .boldSecondaryTextStyling()
                .padding(.bottom, 10)
            
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
                }.padding(.bottom, 10)
                    .zIndex(2)
            } else {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .font(.fredoka(.body, .bold))
                    .padding()
                    .plainStyling()
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
                }.padding(.bottom, 10)
                    .zIndex(1)
                
                VStack(alignment: .leading) {
                    Text("Building")
                        .boldSecondaryTextStyling()
                    
                    TextField("Building, e.g. Priestley", text: $building)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .font(.fredoka(.body, .bold))
                        .padding()
                        .plainStyling()
                        .padding(.bottom, 10)

                    Text("Room")
                        .boldSecondaryTextStyling()
                    
                    TextField("Room, e.g. 03-318", text: $room)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.fredoka(.body, .bold))
                        .padding()
                        .plainStyling()
                }
                
                if !isValid {
                    Text("End time must be after the start time.")
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.redFill)
                }
                
                Spacer()
                
                
                PrimaryButton(title: "Add Class") { save() }
                    .disabled(!canSave)
                
            }
            
        }.padding()
            .containerStyling()
            .alert("These classes overlap", isPresented: $showClashAlert) {
                Button("Add anyway") { insertSessions(pendingTimes) }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(clashText)
            }
            .PopUp(isPresented: $showNoDatesMessage, message: "We don't have dates for this semester yet. Turn off “Repeats every week” to add a single class.", image: "circle-x", colour: Color.redFill, feedback: .error)
        
        
    }
    
    private var clashText: String {
        let hits = clashes(with: existingSessions, newTimes: pendingTimes)
        guard let first = hits.first else { return "" }

        let name = first.course?.courseCode ?? "another class"
        let when = first.start.formatted(.dateTime.weekday(.wide).hour().minute())

        if hits.count == 1 {
            return "This overlaps \(name) on \(when). Both classes will be marked as clashing."
        } else {
            return "This overlaps \(hits.count) classes, starting with \(name) on \(when). All of them will be marked as clashing."
        }
    }
    
    private func makeTimes(from days: [Date]) -> [(start: Date, end: Date)] {
        days.compactMap { day in
            guard let s = combine(day: day, time: start),
                  let e = combine(day: day, time: end) else { return nil }
            return (s, e)
        }
    }
    
    private func save() {
        guard let course else { return }
        
        print("COURSE:", course.courseCode, course.term, course.year)

        // 1. Which days does this class fall on?
        let days: [Date]
        if repeatsWeekly {
            guard let semester = semesterDates(term: course.term, year: course.year) else {
                showNoDatesMessage = true
                return
            }
            days = weeklyDates(weekday: weekday, in: semester)
        } else {
            days = [date]
        }
        
        let times = makeTimes(from: days)
        guard !times.isEmpty else { return }

        if clashes(with: existingSessions, newTimes: times).isEmpty {
            insertSessions(times)
        } else {
            pendingTimes = times
            showClashAlert = true
        }
    }
    
    private func insertSessions (_ times: [(start: Date, end: Date)]) {
        for time in times {
            
            let hits = clashes(with: existingSessions, newTimes: [time])
            hits.forEach { $0.clashable = true }

            let session = ClassSession(start: time.start, end: time.end, type: type, room: room.isEmpty ? nil : room, building: building.isEmpty ? nil : building, course: course, clashable: hits.isEmpty ? nil : true)
            
            modelContext.insert(session)
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        onAdded()
        dismiss()
    }
    
}




#Preview {
    AddClassSheet(){}
        .modelContainer(for: Course.self, inMemory: true)
}
