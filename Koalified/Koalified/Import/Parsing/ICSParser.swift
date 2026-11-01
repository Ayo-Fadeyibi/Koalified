//
//  ICSParser.swift
//  Koalified
//
//  Step 3: turns raw events into `ParsedEvent`s. `parseICS` is the entry point for the import.
//

import Foundation

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
