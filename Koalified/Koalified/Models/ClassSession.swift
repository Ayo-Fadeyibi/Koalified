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
    // Original 5 cases
        case LEC   // Lecture
        case TUT   // Tutorial
        case PRA   // Practical
        case STU   // Studio
        case APP   // Applied Class
        
        // The remaining 13 official UQ session types
        case WKS   // Workshop
        case CLN   // Clinical Teaching
        case SEM   // Seminar
        case EXM   // Exam
        case REC   // Recorded
        case PLM   // Placement
        case FLD   // Fieldwork
        case SYM   // Symposium
        case CON   // Consultation
        case EVT   // Event
        case COM   // IT Computing
        case PAS   // Peer Assisted Study Session (PASS)
    
        case unknown

    /// Localized name shown in the UI.
    var label: LocalizedStringKey {
        switch self {
        case .LEC: "Lecture"
        case .TUT: "Tutorial"
        case .PRA: "Practical"
        case .STU: "Studio"
        case .APP: "Applied"
        case .WKS: "Workshop"
        case .CLN: "Clinical"
        case .SEM: "Seminar"
        case .EXM: "Exam"
        case .REC: "Recorded"
        case .PLM: "Placement"
        case .FLD: "Fieldwork"
        case .SYM: "Symposium"
        case .CON: "Consultation"
        case .EVT: "Event"
        case .COM: "Computing"
        case .PAS: "PASS"
        case .unknown: "Class"
        }
    }

    /// Localized name as a plain `String`, for places that can't take a `LocalizedStringKey` (e.g. the widget snapshot).
    var localizedName: String {
        switch self {
        case .LEC: String(localized: "Lecture")
        case .TUT: String(localized: "Tutorial")
        case .PRA: String(localized: "Practical")
        case .STU: String(localized: "Studio")
        case .APP: String(localized: "Applied")
        case .WKS: String(localized: "Workshop")
        case .CLN: String(localized: "Clinical")
        case .SEM: String(localized: "Seminar")
        case .EXM: String(localized: "Exam")
        case .REC: String(localized: "Recorded")
        case .PLM: String(localized: "Placement")
        case .FLD: String(localized: "Fieldwork")
        case .SYM: String(localized: "Symposium")
        case .CON: String(localized: "Consultation")
        case .EVT: String(localized: "Event")
        case .COM: String(localized: "Computing")
        case .PAS: String(localized: "PASS")
        case .unknown: String(localized: "Class")
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
    var building: String?
    var icsUID: String?
    var course: Course?
    var clashable: Bool?

    init(start: Date, end: Date, type: SessionType, room: String, building: String? = nil, icsUID: String? = nil, course: Course? = nil, clashable: Bool? = nil) {
        self.start = start
        self.end = end
        self.type = type
        self.room = room
        self.building = building
        self.icsUID = icsUID
        self.course = course
        self.clashable = clashable
    }
}
