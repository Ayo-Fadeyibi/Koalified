//
//  ICSParser.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 29/10/2026.
//

import  Foundation

//Important keys to be extracted from .ics file
enum ICSKey: String {
    case uid = "UID"
    case start = "DTSTART"
    case end = "DTEND"
    case summary = "SUMMARY"
    case location = "LOCATION"
    case description = "DESCRIPTION"
}

//Converts the .ics file into a list containing an event disctionary of keys and value
func parseEvents(from text: String) -> [[ICSKey: String]] {
    let lines = text.components(separatedBy: .newlines)
    var events: [[ICSKey: String]] = []
    var current: [ICSKey: String]? = nil

    for line in lines {
        if line == "BEGIN:VEVENT" {
            current = [:]
        } else if line == "END:VEVENT" {
            if let finished = current { events.append(finished) }
            current = nil
        } else if current != nil, let colon = line.firstIndex(of: ":") {
            let left = line[..<colon]
            let value = line[line.index(after: colon)...]
            if let name = left.split(separator: ";").first,
               let key = ICSKey(rawValue: String(name)) {
                current?[key] = String(value)
            }
        }
    }
    return events
}

//Formats the text and replaces /, with , and \n with \n
func unescape(_ text: String) -> String {
    let cleanupComma = text.replacingOccurrences(of: #"\,"#, with: ",")
    let makeNewLine = cleanupComma.replacingOccurrences(of: #"\n"#, with: "\n")
    return makeNewLine
}

//This gets the necessary values from the array list
func item(from parts: [String], at i: Int) -> String? {
    guard parts.indices.contains(i) else { return nil }
    return parts[i]
}

//This breaks the Desciption text into the necessary components
func parseDescription(_ text: String) -> DescriptionInfo? {
    let cleaned = unescape(text)
    let lines = cleaned.components(separatedBy: .newlines)
    
    guard let firstLine = lines.first else { return nil }
    let pieces = firstLine.components(separatedBy: ", ")
    let parts = pieces[0].components(separatedBy: "_")
    
    let title = item(from: lines, at: 1) // String? lgorithms and Data Structures
    let locationLine = item(from: lines, at: 3) ?? "" //01-E112 – St Lucia – Collaborative – Forgan Smith
    let isClashable = locationLine.contains("(Clashable)") // Bool
    let isRecorded = firstLine.contains("Recorded") // Bool
    
    guard let courseCode = item(from: parts, at: 0) else { return nil } //COMP3506
    
    let term: Term? = item(from: parts, at: 1).flatMap { Term(rawValue: $0) }   //S2
    
    let year: Int? = item(from: parts, at: 2).flatMap { Int($0) } //2026
    
    let campus = item(from: parts, at: 3) //STLUCIA
    
    let classNumber = item(from: parts, at: 4) //21275
    
    let mode = item(from: parts, at: 5) //IN
    
    let typeCode: String? = item(from: pieces, at: 1)
        .map { String($0.prefix(while: { $0.isLetter })) } //LEC
    
    var staffName: String?
    if let staffLine = item(from: lines, at: 2), staffLine.hasPrefix("Staff: ") {
        let name = String(staffLine.dropFirst(7))    // "Mackenzie, Joel"
         staffName = (name == "-") ? nil : name
    }
    
    return DescriptionInfo(title: title, courseCode: courseCode, term: term, year: year, campus: campus, classNumber: classNumber, mode: mode, typeCode: typeCode, staffName: staffName, isClashable: isClashable, isRecorded: isRecorded)
}

func makeParsedEvent(from raw: [ICSKey: String]) -> ParsedEvent? {
    guard let UID = raw[.uid] else {return nil}
    
    guard let startText = raw[.start], let start = parseICSDate(startText) else { return nil }
    guard let endText = raw[.end], let end = parseICSDate(endText) else { return nil }
    
    guard let descriptionText = raw[.description],
              let info = parseDescription(descriptionText) else { return nil }

    let type: SessionType? = info.typeCode.flatMap { SessionType(rawValue: $0) }
    let location = raw[.location].map(unescape)
    
    return ParsedEvent(uid: UID, courseCode: info.courseCode, title: info.title, start: start, end: end, location: location, term: info.term, year: info.year, type: type, typeCode: info.typeCode, staff: info.staffName, campus: info.campus, classNumber: info.classNumber, isClashable: info.isClashable, isRecorded: info.isRecorded)
}

func parseICS(_ text: String) -> [ParsedEvent] {
    // 1. rawEvents from parseEvents(from: text)
    let rawEvents = parseEvents(from: text)
    // 2. compactMap to ParsedEvents
    let events: [ParsedEvent] = rawEvents.compactMap { makeParsedEvent(from: $0) }
    // 3. return them
    return events
}

func detectSemesters(from events: [ParsedEvent]) -> [DetectedSemester] {
    let groups = Dictionary(grouping: events, by: { SemesterKey(term: $0.term, year: $0.year) })

    let result = groups.map { key, bucket in
        // build one DetectedSemester from this key and its bucket
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
