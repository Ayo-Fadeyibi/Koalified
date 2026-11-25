//
//  CourseColour.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

/// The accent colours a course can be given. Stored by name so it can be saved with the course.
enum CourseColor: String, Codable, CaseIterable {
    case teal, blue, amber, rose, violet, green, red, indigo, orange, yellow, fuchsia

    /// The SwiftUI colour for this choice.
    var color: Color {
        switch self {
        case .teal:    return Color.courseTeal
        case .blue:    return Color.courseBlue
        case .amber:   return Color.courseAmber
        case .rose:    return Color.courseRose
        case .violet:  return Color.courseViolet
        case .green:   return Color.courseGreen
        case .red:     return Color.courseRed
        case .indigo:  return Color.courseIndigo
        case .orange:  return Color.courseOrange
        case .yellow:  return Color.courseYellow
        case .fuchsia: return Color.courseFuchsia
        }
    }

    /// Text and icons drawn on top of this colour. Yellow and orange are too bright for white,
    /// so they get dark ink (`onMint` stays dark in both modes); the deeper colours get white.
    var onColor: Color {
        switch self {
        case .yellow, .orange: return Color.onMint
        default:               return .white
        }
    }

    /// Turns the string saved on a Course into a Color. Unknown names fall back to grey.
    static func color(for name: String) -> Color {
        CourseColor(rawValue: name)?.color ?? .gray
    }
}
