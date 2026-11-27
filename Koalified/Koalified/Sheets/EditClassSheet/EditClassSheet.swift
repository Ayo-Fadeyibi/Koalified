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
    @State private var date = Date.now

    /// Every session except the one being edited, so it never counts as clashing with itself.
    private var otherSessions: [ClassSession] {
        existingSessions.filter { $0 !== selectedSession }
    }

    private var isValid: Bool { timesAreValid(from: start, to: end) }
    private var canSave: Bool { course != nil && isValid }

    @State private var showClashLimitMessage = false
    @State private var pendingTimes: [(start: Date, end: Date)] = []
    @State private var showClashAlert = false

    let onAdded: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(selectedSession == nil ? "Add a class" : "Edit class")
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
                    
                    PopoverDatePicker(title: "Date", selection: $date)
                    
                }.padding(.bottom, 24)
                    .zIndex(2)
            
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
                
                
                PrimaryButton(title: "Save") { save() }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                
            }
            
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .onAppear {
                // Prefill the form from the class being edited. Only the hour and minute of
                // `start`/`end` are used when saving, so the session's own dates can go straight in.
                guard let selectedSession else { return }
                course = selectedSession.course
                type = selectedSession.type
                date = selectedSession.start
                start = selectedSession.start
                end = selectedSession.end
                building = selectedSession.building ?? ""
                room = selectedSession.room ?? ""
            }
            .alert("These classes overlap", isPresented: $showClashAlert) {
                Button("Add anyway") { insertSessions(pendingTimes) }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(clashMessage(for: clashes(with: otherSessions, newTimes: pendingTimes)))
            }
            .PopUp(isPresented: $showClashLimitMessage, message: "No more than \(maxClashingClasses) classes can clash at once. Choose a different time for this class.", image: "circle-x", colour: Color.redFill, feedback: .error)
    }

    private func save() {
        guard course != nil else { return }

        let times = classTimes(on: [date], start: start, end: end)
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
