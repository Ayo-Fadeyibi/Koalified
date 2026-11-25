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
    
    private var currentSemesterCourses: [Course] {
        guard let newest = courses.newestFirst.first else { return [] }
        return courses.filter { $0.year == newest.year && $0.term == newest.term }
    }

    private var isValid: Bool { timesAreValid(from: start, to: end) }
    
    let onAdded: () -> Void
    
    @State private var openAddCourseSheet = false
    @State private var openImportSheet = false
    @State private var showError = false
    @State private var errorMessage: LocalizedStringKey = ""
    @State private var pendingTimes: [(start: Date, end: Date)] = []
    @State private var showClashAlert = false
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add a class")
                .primaryTextStyling()
                .padding(.bottom, 20)
            
            if courses.isEmpty {
                EmptyStateView(
                    title1: "No courses yet",
                    message1: "Add a course before adding a class, or import your timetable to add courses and classes.",
                    primaryTitle1: "Add a course",
                    primaryAction1: { openAddCourseSheet = true },
                    secondaryTitle: "Import timetable",
                    secondaryAction: { openImportSheet = true }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ClassForm(
                    currentSemesterCourses: currentSemesterCourses,
                    course: $course,
                    type: $type,
                    start: $start,
                    end: $end,
                    building: $building,
                    room: $room,
                    weekday: $weekday,
                    repeatsWeekly: $repeatsWeekly,
                    date: $date,
                    isValid: isValid,
                    onSave: save
                )
            }
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .sheet(isPresented: $openAddCourseSheet) {
                AddCourseSheet()
                    .sheetBorder()
            }
            .sheet(isPresented: $openImportSheet) {
                ImportLinkSheet()
                    .sheetBorder()
            }
            .alert("These classes overlap", isPresented: $showClashAlert) {
                Button("Add anyway") { insertSessions(pendingTimes) }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(clashText)
            }
            .PopUp(isPresented: $showError, message: errorMessage, image: "circle-x", colour: Color.redFill, feedback: .error)
        
        
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
        guard let course else {
            errorMessage = "Choose a course."
            showError = true
            return
        }

        guard isValid else {
            errorMessage = "End time must be after the start time."
            showError = true
            return
        }
        
        print("COURSE:", course.courseCode, course.term, course.year)

        // 1. Which days does this class fall on?
        let days: [Date]
        if repeatsWeekly {
            guard let semester = semesterDates(term: course.term, year: course.year) else {
                errorMessage = "We don't have dates for this semester yet. Turn off “Repeats every week” to add a single class."
                showError = true
                return
            }
            days = weeklyDates(weekday: weekday, in: semester)
        } else {
            days = [date]
        }
        
        let times = makeTimes(from: days)
        guard !times.isEmpty else { return }

        guard !exceedsClashLimit(existing: existingSessions, newTimes: times) else {
            errorMessage = "No more than \(maxClashingClasses) classes can clash at once. Choose a different time for this class."
            showError = true
            return
        }

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
        .modelContainer(PreviewData.container)
}
