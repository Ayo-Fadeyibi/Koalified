//
//  ClassModel.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import Foundation

/// A lightweight, non-persisted class occurrence used for display (e.g. the sample agenda).
struct ClassEvent: Identifiable {
    let id = UUID()         // Unique ID for each event
    let courseCode: String  // Course code
    let kind: SessionType        // "Lecture", "Tutorial"
    let room: String        // room number
    let start: Date         // Event start time/date
    let end: Date           // Event end time/date
}





