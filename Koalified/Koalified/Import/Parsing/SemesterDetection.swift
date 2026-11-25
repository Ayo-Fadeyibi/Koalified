//
//  SemesterDetection.swift
//  Koalified
//
//  Groups parsed events into semesters and finds the events belonging to one semester.
//

import Foundation

/// The semesters in the events, newest first. Events with no term or year are grouped together and sort last.
func detectSemesters(from events: [ParsedEvent]) -> [DetectedSemester] {
    Dictionary(grouping: events, by: { SemesterKey(term: $0.term, year: $0.year) })
        .map { key, bucket in
            DetectedSemester(term: key.term, year: key.year,
                             courseCount: Set(bucket.map(\.courseCode)).count,
                             classCount: bucket.count)
        }
        .sorted {
            // A missing year or term counts as 0, so it sorts last.
            let year0 = $0.year ?? 0, year1 = $1.year ?? 0
            if year0 != year1 { return year0 > year1 }
            return ($0.term?.sortOrder ?? 0) > ($1.term?.sortOrder ?? 0)
        }
}


func events(in semester: DetectedSemester, from events: [ParsedEvent]) -> [ParsedEvent] {
    events.filter { $0.term == semester.term && $0.year == semester.year }
}
