//
//  EditClassSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/11/2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct EditClassSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @Query private var existingSessions: [ClassSession]

    let selectedSession: ClassSession? 
    @State private var course: Course?
    @State private var type: SessionType = .LEC
    // Default to 9:00-10:00 so the form is valid whatever time the sheet is opened
    @State private var start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
    @State private var end = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now) ?? .now.addingTimeInterval(3600)
    @State private var building = ""
    @State private var room = ""
    @State private var weekday = 2   // 1 = Sunday ... 7 = Saturday, so 2 = Monday
    @State private var date = Date.now
    
    /// Every session except the one being edited, so it never counts as clashing with itself.
    private var otherSessions: [ClassSession] {
        existingSessions.filter { $0 !== selectedSession }
    }

    private var isValid: Bool { timesAreValid(from: start, to: end) }
    private var canSave: Bool { Koalified.canSave(course: course, valid: isValid) }
    
    
    @State private var showNoDatesMessage = false
    @State private var showClashLimitMessage = false
    @State private var pendingTimes: [(start: Date, end: Date)] = []
    @State private var showClashAlert = false
    
    @FocusState private var isBuildingInputFocused: Bool
    @FocusState private var isRoomInputFocused: Bool
    
    let onAdded: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add a class")
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
            }.padding(.bottom, 24)
                .zIndex(3)
            
       
                VStack(alignment: .leading) {
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .font(.fredoka(.body, .bold))
                        .padding()
                        .plainStyling()
                    
                }.padding(.bottom, 24)
                    .zIndex(2)
            
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
                
                
                PrimaryButton(title: "Save") { save() }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                
            }
            
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear{
                
                var calendar = Calendar(identifier: .iso8601)
                calendar.timeZone = .current
                calendar.locale = .current
                
                if let savedCourseCode = selectedSession?.course{
                    course = savedCourseCode
                }
                
                if let savedSessionType = selectedSession?.type {
                    type = savedSessionType
                }
                
                if let savedDate = selectedSession?.start {
                    date = savedDate
                }
                
                if let savedStartTime = selectedSession?.start {
                       
                    let hour   = calendar.component(.hour, from: savedStartTime)
                    let minute = calendar.component(.minute, from: savedStartTime)
                    let second = calendar.component(.second, from: savedStartTime)
                    
                    start = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: .now) ?? .now
                }
                
                if let savedEndTime = selectedSession?.end {
                       
                    let hour   = calendar.component(.hour, from: savedEndTime)
                    let minute = calendar.component(.minute, from: savedEndTime)
                    let second = calendar.component(.second, from: savedEndTime)
                    
                    end = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: .now) ?? .now.addingTimeInterval(3600)
                }
                
                if let savedBuilding = selectedSession?.building {
                    building = savedBuilding
                }
                
                if let savedRoom = selectedSession?.room {
                    room = savedRoom
                }
            }
            .alert("These classes overlap", isPresented: $showClashAlert) {
                Button("Add anyway") { insertSessions(pendingTimes) }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(clashText)
            }
            .PopUp(isPresented: $showNoDatesMessage, message: "We don't have dates for this semester yet. Turn off “Repeats every week” to add a single class.", image: "circle-x", colour: Color.redFill, feedback: .error)
            .PopUp(isPresented: $showClashLimitMessage, message: "No more than \(maxClashingClasses) classes can clash at once. Choose a different time for this class.", image: "circle-x", colour: Color.redFill, feedback: .error)
        
        
    }
    
    private var clashText: String {
        let hits = clashes(with: otherSessions, newTimes: pendingTimes)
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
    
            days = [date]
        
        
        let times = makeTimes(from: days)
        guard !times.isEmpty else { return }

        guard !exceedsClashLimit(existing: otherSessions, newTimes: times) else {
            showClashLimitMessage = true
            return
        }

        if clashes(with: otherSessions, newTimes: times).isEmpty {
            insertSessions(times)
        } else {
            pendingTimes = times
            showClashAlert = true
        }
    }
    
    private func insertSessions (_ times: [(start: Date, end: Date)]) {
        for time in times {
            
            let hits = clashes(with: otherSessions, newTimes: [time])
            hits.forEach { $0.clashable = true }
            
            if let selectedSession {
                
                selectedSession.course = course
                selectedSession.start = time.start
                selectedSession.end = time.end
                selectedSession.type = type
                selectedSession.building = building.isEmpty ? nil : building
                selectedSession.room = room.isEmpty ? nil : room
                selectedSession.clashable = hits.isEmpty ? nil : true
                
            } else {
                
                let session = ClassSession(start: time.start, end: time.end, type: type, room: room.isEmpty ? nil : room, building: building.isEmpty ? nil : building, course: course, clashable: hits.isEmpty ? nil : true)
                modelContext.insert(session)
                
            }
            
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        onAdded()
        dismiss()
    }
    
}




#Preview {
    EditClassSheet(selectedSession: nil){}
        .modelContainer(for: Course.self, inMemory: true)
}
