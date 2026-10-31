//
//  ICSImporter.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftData

struct ImportResult: Hashable {
    var added = 0
    var updated = 0
    var unchanged = 0
    var skipped = 0   // events with no term or year
}

//Handles importation and update of timetable
func importEvents(_ events: [ParsedEvent], into context: ModelContext) throws -> ImportResult {
    var result = ImportResult()

    // Everything already stored, looked up by UID
    let stored = try context.fetch(FetchDescriptor<ClassSession>())
    var byUID: [String: ClassSession] = [:]
    for session in stored {
        if let uid = session.icsUID { byUID[uid] = session }
    }

    var courses = try context.fetch(FetchDescriptor<Course>())

    for event in events {
        guard let term = event.term, let year = event.year else {
            result.skipped += 1
            continue
        }

        // Find the course, or create it
        let course: Course
        if let found = courses.first(where: { $0.courseCode == event.courseCode && $0.term == term && $0.year == year }) {
            course = found
        } else {
            let sameSemester = courses.filter { $0.term == term && $0.year == year }.count
            let colour = CourseColor.allCases[sameSemester % CourseColor.allCases.count]
            course = Course(courseCode: event.courseCode, title: event.title, term: term, year: year, color: colour)
            context.insert(course)
            courses.append(course)
        }

        // TODO: session logic goes here
        if let existing = byUID[event.uid] {
            let newType = event.type ?? .unknown
            let newRoom = event.location ?? ""

            if existing.start != event.start || existing.end != event.end
                || existing.type != newType || existing.room != newRoom {
                // update the fields on existing
                existing.start = event.start
                existing.end = event.end
                existing.room = newRoom
                existing.type = newType
                result.updated += 1
            } else {
                result.unchanged += 1
            }
            
        } else {
            let session = ClassSession(start: event.start, end: event.end,
                                       type: event.type ?? .unknown,
                                       room: event.location ?? "",
                                       icsUID: event.uid, course: course)
            context.insert(session)
            result.added += 1
        }
    }

    return result
}
