//
//  AssessmentItem.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import Foundation
import SwiftData

@Model
final class AssessmentItem {
    var title: String
    var weight: Double // percent of the final grade, e.g. 15
    var dueDate: Date
    var mark: Double?
    var course: Course?
    
    init(title: String, weight: Double, dueDate: Date, mark: Double? = nil, course: Course? = nil) {
        self.title = title
        self.weight = weight
        self.dueDate = dueDate
        self.mark = mark
        self.course = course
    }
}
