//
//  CourseColour.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

/// The accent colours a course can be given. Stored by name so it can be saved with the course.
enum CourseColor: String, Codable, CaseIterable {
    case teal, blue, amber, rose

    /// The SwiftUI colour for this choice.
    var color: Color {
        switch self {
        case .teal:  return Color.newTeal
        case .blue:  return Color.newBlue
        case .amber: return Color.newAmber
        case .rose:  return Color.newRose
        }
    }

    /// Turns the string saved on a Course into a Color. Unknown names fall back to grey.
    static func color(for name: String) -> Color {
        CourseColor(rawValue: name)?.color ?? .gray
    }
}
