//
//  ICSReader.swift
//  Koalified
//
//  Step 1: reads the raw .ics text into key/value events, plus small text helpers.
//

import Foundation

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
