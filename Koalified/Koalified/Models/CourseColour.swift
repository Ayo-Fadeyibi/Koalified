//
//  CourseColour.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

enum CourseColor: String, Codable, CaseIterable {
    case teal, blue, amber, rose

    var color: Color {
        switch self {
        case .teal:  return Color.teal
        case .blue:  return Color.blue
        case .amber: return Color.amber
        case .rose:  return Color.rose
        }
    }

    /// Turns the string saved on a Course into a Color. Unknown names fall back to grey.
    static func color(for name: String) -> Color {
        CourseColor(rawValue: name)?.color ?? .gray
    }
}
