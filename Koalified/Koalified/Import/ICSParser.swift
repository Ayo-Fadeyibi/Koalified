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
    
    return DescriptionInfo(courseCode: courseCode, term: term, year: year, campus: campus, classNumber: classNumber, mode: mode, typeCode: typeCode, staffName: staffName)
    // …
}

//func makeParsedEvent(from raw: [ICSKey: String]) -> ParsedEvent? {
//    // ...
//}
