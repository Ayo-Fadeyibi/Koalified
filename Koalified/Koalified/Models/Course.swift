import Foundation
import SwiftData

@Model
final class Course {
    var courseCode: String
    var title: String?
    var semester: String
    var color: CourseColor
    var censusDate: Date?
    var lastDropDate: Date?

    @Relationship(deleteRule: .cascade)
    var sessions: [ClassSession] = []

    @Relationship(deleteRule: .cascade)
    var assessments: [AssessmentItem] = []

    init(courseCode: String,
         title: String? = nil,
         semester: String,
         color: CourseColor,
         censusDate: Date? = nil,
         lastDropDate: Date? = nil) {
        self.courseCode = courseCode
        self.title = title
        self.semester = semester
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
