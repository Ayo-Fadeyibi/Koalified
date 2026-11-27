import Foundation

/// One semester that has courses, e.g. Semester 2, 2026; an option in the Courses screen's semester picker.
struct SemesterChoice: Hashable {
    let term: Term
    let year: Int

    var label: String { "\(term.label), \(year)" }

    func contains(_ course: Course) -> Bool {
        course.term == term && course.year == year
    }
}

extension Array where Element == Course {
    /// Courses sorted newest semester first.
    var newestFirst: [Course] {
        sorted {
            $0.year == $1.year ? $0.term.sortOrder > $1.term.sortOrder : $0.year > $1.year
        }
    }

    /// The courses in the newest semester; empty when there are no courses.
    var currentSemester: [Course] {
        guard let newest = newestFirst.first else { return [] }
        return filter { $0.year == newest.year && $0.term == newest.term }
    }

    /// Every semester that has at least one course, newest first.
    var semesterChoices: [SemesterChoice] {
        Set(map { SemesterChoice(term: $0.term, year: $0.year) }).sorted {
            $0.year == $1.year ? $0.term.sortOrder > $1.term.sortOrder : $0.year > $1.year
        }
    }
}
