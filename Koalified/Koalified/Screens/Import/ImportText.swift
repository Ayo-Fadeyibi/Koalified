//
//  ImportText.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import Foundation

/// "1 course", "4 courses". Pass `many` for irregular plurals such as "class" / "classes".
func plural(_ n: Int, _ one: String, _ many: String? = nil) -> String {
    "\(n) \(n == 1 ? one : (many ?? one + "s"))"
}

extension DetectedSemester {
    /// "Semester 2, 2026", or "Other classes" when the term or year is missing.
    var title: String {
        guard let term, let year else { return "Other classes" }
        return "\(term.label), \(year)"
    }
}
