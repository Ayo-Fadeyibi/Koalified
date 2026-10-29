//
//  ICSParser.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 29/10/2026.
//

import  Foundation

enum ICSKey: String {
    case uid = "UID"
    case start = "DTSTART"
    case end = "DTEND"
    case summary = "SUMMARY"
    case location = "LOCATION"
    case description = "DESCRIPTION"
}

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
