import Foundation
import SwiftData

enum Term: String, Codable, CaseIterable {
    case semester1, semester2, summer

    var label: String {
        switch self {
        case .semester1: return "Semester 1"
        case .semester2: return "Semester 2"
        case .summer:    return "Summer"
        }
    }
}

@Model
final class Course {
    var courseCode: String
    var title: String?
    var term: Term
    var year: Int
    var semesterLabel: String { "\(term.label), \(year)" }
    var color: CourseColor
    var censusDate: Date?
    var lastDropDate: Date?

    @Relationship(deleteRule: .cascade)
    var sessions: [ClassSession] = []

    @Relationship(deleteRule: .cascade)
    var assessments: [AssessmentItem] = []

    init(courseCode: String,
         title: String? = nil,
         term: Term,
         year: Int,
         color: CourseColor,
         censusDate: Date? = nil,
         lastDropDate: Date? = nil) {
        self.courseCode = courseCode
        self.title = title
        self.term = term
        self.year = year
        self.color = color
        self.censusDate = censusDate
        self.lastDropDate = lastDropDate
    }

    /// Points earned so far: weight × mark ÷ 100 for every assessment that has a mark.
    var earnedPoints: Double {
        assessments.reduce(0) { total, item in
            guard let mark = item.mark else { return total }
            return total + item.weight * mark / 100
        }
    }
}
