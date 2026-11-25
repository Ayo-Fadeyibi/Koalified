import Foundation

/// A group of courses that share a semester, e.g. "Semester 1, 2026".
struct SemesterSection: Identifiable {
    let id: String
    let title: String
    let courses: [Course]
}

extension Array where Element == Course {
    /// Courses sorted newest semester first.
    var newestFirst: [Course] {
        sorted {
            $0.year == $1.year ? $0.term.sortOrder > $1.term.sortOrder : $0.year > $1.year
        }
    }

    /// The distinct years across the courses, newest first, e.g. [2026, 2025, 2024].
    var availableYears: [Int] {
        Set(map { $0.year }).sorted(by: >)
    }

    /// The distinct terms across the courses, latest in the year first.
    var availableSemesters: [Term] {
        Set(map { $0.term }).sorted { $0.sortOrder > $1.sortOrder }
    }

    /// Groups the courses into one section per semester, newest first.
    var semesterSections: [SemesterSection] {
        let groups = Dictionary(grouping: self, by: { SemesterKey(term: $0.term, year: $0.year) })
        let keys = groups.keys.sorted {
            let year0 = $0.year ?? 0
            let year1 = $1.year ?? 0
            if year0 != year1 { return year0 > year1 }
            return ($0.term?.sortOrder ?? 0) > ($1.term?.sortOrder ?? 0)
        }

        return keys.compactMap { key in
            guard let term = key.term, let year = key.year else { return nil }
            return SemesterSection(
                id: "\(term.rawValue)-\(year)",
                title: "\(term.label), \(year)",
                courses: groups[key] ?? []
            )
        }
    }
}
