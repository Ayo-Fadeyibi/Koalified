//
//  ClassModel.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import Foundation

struct ClassEvent: Identifiable {
    let id = UUID()         // Unique ID for each event
    let courseCode: String  // Course code
    let kind: String        // "Lecture", "Tutorial"
    let room: String        // room number
    let start: Date         // Event start time/date
    let end: Date           // Event end time/date
}

struct Language: Identifiable {
    let id = UUID()
    let native: String  // 简体中文
    let english: String // Chinese (Simplified)
}
