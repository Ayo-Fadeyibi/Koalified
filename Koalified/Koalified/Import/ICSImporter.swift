//
//  ICSImporter.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import Foundation
import SwiftData

struct ImportResult: Hashable {
    var added = 0
    var updated = 0
    var unchanged = 0
    var skipped = 0   // events with no term or year
}

/// Pulls the building name out of a location like "46-230 – St Lucia – Collaborative – Andrew N. Liveris".
/// The building is the last " – " part; returns nil when the location has fewer than 4 parts (e.g. online).
func buildingName(from location: String?) -> String? {
    guard let location else { return nil }
    let parts = location.components(separatedBy: " – ")
    guard parts.count >= 4, let last = parts.last else { return nil }
    let name = last.trimmingCharacters(in: .whitespaces)
    return name.isEmpty ? nil : name
}

/// Pulls the room code out of a location like "46-230 – St Lucia – Collaborative – Andrew N. Liveris".
/// The room is the first " – " part; a location with a single part is returned as is, and nil gives "".
func roomCode(from location: String?) -> String {
    guard let location else { return "" }
    let first = location.components(separatedBy: " – ").first ?? location
    return first.trimmingCharacters(in: .whitespaces)
}

/// Adds the events as class sessions (creating their courses as needed), or updates the ones already imported.
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
            let colour = CourseColor.selectable[sameSemester % CourseColor.selectable.count]
            course = Course(courseCode: event.courseCode, title: event.title, term: term, year: year, color: colour)
            context.insert(course)
            courses.append(course)
        }

        let type = event.type ?? .unknown
        let room = roomCode(from: event.location)
        let building = buildingName(from: event.location)

        // Already imported: update it if the timetable changed.
        if let existing = byUID[event.uid] {
            if existing.start != event.start || existing.end != event.end
                || existing.type != type || existing.room != room
                || existing.building != building {
                existing.start = event.start
                existing.end = event.end
                existing.room = room
                existing.building = building
                existing.type = type
                result.updated += 1
            } else {
                result.unchanged += 1
            }
        } else {
            let session = ClassSession(start: event.start, end: event.end, type: type,
                                       room: room, building: building,
                                       icsUID: event.uid, course: course, clashable: event.isClashable)
            context.insert(session)
            result.added += 1
        }
    }

    return result
}
