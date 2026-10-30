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
        case ALL   // All / Miscellaneous (Used as a generic system catch-all
    
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
        case .ALL: "Class"
        case .unknown: "Class"
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
