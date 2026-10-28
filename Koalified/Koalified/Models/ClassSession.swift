//
//  ClassSession.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//
import Foundation
import SwiftData
import SwiftUI

/// The kind of class a session is.
enum SessionType: String, Codable {
       case lecture, tutorial, practical

    /// Localized name shown in the UI.
    var label: LocalizedStringKey {
        switch self {
        case .lecture: "Lecture"
        case .tutorial: "Tutorial"
        case .practical: "Practical"
        }
    }
   }

/// One scheduled class (lecture, tutorial or practical) for a course, with its time and room.
/// `icsUID` is the event's ID in an imported calendar file, used to recognise it on re-import.
@Model
final class ClassSession {
    var start: Date
    var end: Date
    var type: SessionType
    var room: String
    var icsUID: String?
    var course: Course?
    
    init(start: Date, end: Date, type: SessionType, room: String, icsUID: String? = nil, course: Course? = nil) {
        self.start = start
        self.end = end
        self.type = type
        self.room = room
        self.icsUID = icsUID
        self.course = course
    }
}
