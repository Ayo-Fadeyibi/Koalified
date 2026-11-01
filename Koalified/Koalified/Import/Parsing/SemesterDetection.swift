//
//  SemesterDetection.swift
//  Koalified
//
//  Groups parsed events into semesters and finds the events belonging to one semester.
//

import Foundation

func detectSemesters(from events: [ParsedEvent]) -> [DetectedSemester] {
    let groups = Dictionary(grouping: events, by: { SemesterKey(term: $0.term, year: $0.year) })

    let result = groups.map { key, bucket in
        // build DetectedSemester from this key and its bucket
        let codes = Set(bucket.map { $0.courseCode })   // {"COMP3506", "CSSE3200", ...}
        let courseCount = codes.count
        
        let term = key.term
        let year = key.year
        
        let classCount = bucket.count
        
        return DetectedSemester(term: term, year: year, courseCount: courseCount, classCount: classCount)
        
    }
    
    return result.sorted {
        let year0 = $0.year ?? 0      // a missing year counts as 0, so it sorts last
        let year1 = $1.year ?? 0
        if year0 != year1 { return year0 > year1 } else {
            let term0 = $0.term?.sortOrder ?? 0
            let term1 = $1.term?.sortOrder ?? 0
            
            return term0 > term1
        }
    
    }
}


func events(in semester: DetectedSemester, from events: [ParsedEvent]) -> [ParsedEvent] {
    return events.filter { $0.term == semester.term && $0.year == semester.year }
}
