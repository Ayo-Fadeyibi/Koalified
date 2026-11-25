//
//  AssessmentItem.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import Foundation
import SwiftData

/// A graded piece of work (assignment, quiz, exam) belonging to a course.
/// `mark` is nil until the result is known.
@Model
final class AssessmentItem {
    var title: String
    var weight: Double // percent of the final grade, e.g. 15
    var dueDate: Date
    var mark: Double?
    /// The raw score the user entered (e.g. 17 in "17 out of 20"); `mark` holds it as a percentage.
    var markScore: Double?
    /// What the raw score was out of (e.g. 20 in "17 out of 20").
    var markOutOf: Double?
    var course: Course?
    var hurdle: Bool?
    var hurdlePercent: Int?
    /// Marked as done in the wallet (the ticket's stub has been ripped off).
    var isDone: Bool = false

    init(title: String, weight: Double, dueDate: Date, mark: Double? = nil, course: Course? = nil, hurdle: Bool? = nil, hurdlePercent: Int? = nil, isDone: Bool = false) {
        self.title = title
        self.weight = weight
        self.dueDate = dueDate
        self.mark = mark
        self.course = course
        self.hurdle = hurdle
        self.hurdlePercent = hurdlePercent
        self.isDone = isDone
    }
}
