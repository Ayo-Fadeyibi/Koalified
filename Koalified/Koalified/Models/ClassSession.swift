//
//  ClassSession.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//
import Foundation
import SwiftData
import SwiftUI

enum SessionType: String, Codable {
       case lecture, tutorial, practical
    
    var label: LocalizedStringKey {
        switch self {
        case .lecture: "Lecture"
        case .tutorial: "Tutorial"
        case .practical: "Practical"
        }
    }
   }

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
