//
//  ParseEventsTest.swift
//  KoalifiedUnitTests
//

import XCTest
@testable import Koalified

let sampleDate = #"""
BEGIN:VCALENDAR
PRODID:-//Allocate//iCal4j 1.0//EN
VERSION:2.0
CALSCALE:GREGORIAN
BEGIN:VTIMEZONE
TZID:Australia/Brisbane
LAST-MODIFIED:20260306T231828Z
TZURL:https://www.tzurl.org/zoneinfo-outlook/Australia/Brisbane
X-LIC-LOCATION:Australia/Brisbane
BEGIN:STANDARD
TZNAME:AEST
TZOFFSETFROM:+1000
TZOFFSETTO:+1000
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
DTSTAMP:20261029T100304Z
DTSTART;TZID=Australia/Brisbane:20260305T140000
DTEND;TZID=Australia/Brisbane:20260305T150000
SUMMARY:Functional and Logic Programming\, APP01
LOCATION:09-221 – St Lucia – Seminar – Michie
DESCRIPTION:COMP3400_S1_2026_STLUCIA_21275_IN\, APP01\, 07\nFunctional and Logic Programming\nStaff: -\nLocation: 09-221 – St Lucia – Seminar – Michie
UID:uid0
END:VEVENT
BEGIN:VEVENT
DTSTAMP:20261029T100304Z
DTSTART;TZID=Australia/Brisbane:20260312T140000
DTEND;TZID=Australia/Brisbane:20260312T150000
SUMMARY:Functional and Logic Programming\, APP01
LOCATION:09-221 – St Lucia – Seminar – Michie
DESCRIPTION:COMP3400_S1_2026_STLUCIA_21275_IN\, APP01\, 07\nFunctional and Logic Programming\nStaff: -\nLocation: 09-221 – St Lucia – Seminar – Michie
UID:uid1
END:VEVENT
BEGIN:VEVENT
DTSTAMP:20261029T100304Z
DTSTART;TZID=Australia/Brisbane:20260319T140000
DTEND;TZID=Australia/Brisbane:20260319T150000
SUMMARY:Functional and Logic Programming\, APP01
LOCATION:09-221 – St Lucia – Seminar – Michie
DESCRIPTION:COMP3400_S1_2026_STLUCIA_21275_IN\, APP01\, 07\nFunctional and Logic Programming\nStaff: -\nLocation: 09-221 – St Lucia – Seminar – Michie
UID:uid2
END:VEVENT
"""#

final class ParseEventsTests: XCTestCase {
    
    func testParsesThreeEvents() {
        let events = parseEvents(from: sampleDate)
        print("events found:", events.count)
        XCTAssertEqual(events.count, 3)
    }
    
    func testIgnoresTimezoneBlock() {
        // The VTIMEZONE block has a DTSTART (1970) that must not become an event.
        let events = parseEvents(from: sampleDate)
        XCTAssertFalse(events.contains { $0[.start]?.contains("1970") == true })
    }
    
    func testReadsKeysWithParameters() {
        // DTSTART;TZID=Australia/Brisbane:20260305T140000 -> key DTSTART, value after the first colon
        let first = parseEvents(from: sampleDate).first
        XCTAssertEqual(first?[.start], "20260305T140000")
        XCTAssertEqual(first?[.uid], "uid0")
    }
    
    func testParsesBrisbaneDate() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Australia/Brisbane")!
        
        let parts = DateComponents(year: 2026, month: 3, day: 5, hour: 14, minute: 0)
        let expected = try XCTUnwrap(calendar.date(from: parts))   // returns Date?
        XCTAssertEqual(parseICSDate("20260305T140000"), expected)
    }
    
    func testRejectsBadInput() {
        XCTAssertNil(parseICSDate("banana"))
        XCTAssertNil(parseICSDate(""))
        XCTAssertNil(parseICSDate("2026-03-05"))   // wrong format, with dashes
    }
    
    func testUnEscape() {
        let text = unescape(#"Staff: Mackenzie\, Joel"#)
        let expected = "Staff: Mackenzie, Joel"
        XCTAssertEqual(text, expected)
    }
    
    func testUnescapeNewline() {
        let text = unescape(#"Line one\nLine two"#)
        XCTAssertEqual(text, "Line one\nLine two")
    }
    
    func testParseDescription() throws {
        let text = #"COMP3506_S2_2026_STLUCIA_60789_IN\, LEC01\, 01_Recorded\nAlgorithms and Data Structures\nStaff: Mackenzie\, Joel\nLocation: Delayed viewing (Clashable)"#
        let info = try XCTUnwrap(parseDescription(text))
        
        let courseCode = info.courseCode
        let term = info.term
        let staffName = info.staffName
        
        XCTAssertEqual("COMP3506", courseCode)
        XCTAssertEqual(Term.S2, term)
        XCTAssertEqual("Mackenzie, Joel", staffName)
        XCTAssertTrue(info.isRecorded)
        XCTAssertTrue(info.isClashable)
    }
    
    func testParseICS() throws {
        let events = parseICS(sampleDate)
        XCTAssertEqual(events.count, 3)

        let first = try XCTUnwrap(events.first)
        // add assertions for first.uid, first.courseCode, first.term, first.year, first.type
        XCTAssertEqual(first.uid, "uid0")
        XCTAssertEqual(first.courseCode, "COMP3400")
        XCTAssertEqual(first.term, Term.S1)
        XCTAssertEqual(first.year, 2026)
        XCTAssertEqual(first.type, SessionType.APP)
    }
    
    // Builds one VEVENT in the same shape as your real file.
    private func makeEvent(uid: String, code: String, term: String) -> String {
        #"""
        BEGIN:VEVENT
        DTSTART;TZID=Australia/Brisbane:20260305T140000
        DTEND;TZID=Australia/Brisbane:20260305T150000
        SUMMARY:Test class\, APP01
        LOCATION:09-221 – St Lucia – Seminar – Michie
        DESCRIPTION:\#(code)_\#(term)_2026_STLUCIA_21275_IN\, APP01\, 07\nTest class\nStaff: -\nLocation: 09-221
        UID:\#(uid)
        END:VEVENT
        """#
    }

    func testDetectSemestersNewestFirst() {
        let text = [
            "BEGIN:VCALENDAR",
            makeEvent(uid: "a", code: "COMP3400", term: "S1"),
            makeEvent(uid: "b", code: "COMP3400", term: "S1"),
            makeEvent(uid: "c", code: "COMP3506", term: "S2"),
            "END:VCALENDAR"
        ].joined(separator: "\n")

        let semesters = detectSemesters(from: parseICS(text))

        XCTAssertEqual(semesters.count, 2)
        // newest first: S2 before S1
        XCTAssertEqual(semesters[0].term, Term.S2)
        XCTAssertEqual(semesters[0].classCount, 1)
        XCTAssertEqual(semesters[0].courseCount, 1)
        XCTAssertEqual(semesters[1].term, Term.S1)
        XCTAssertEqual(semesters[1].classCount, 2)
        XCTAssertEqual(semesters[1].courseCount, 1)
    }

    func testEventsInSemesterKeepsOnlyThatSemester() {
        let text = [
            "BEGIN:VCALENDAR",
            makeEvent(uid: "a", code: "COMP3400", term: "S1"),
            makeEvent(uid: "b", code: "COMP3400", term: "S1"),
            makeEvent(uid: "c", code: "COMP3506", term: "S2"),
            "END:VCALENDAR"
        ].joined(separator: "\n")

        let parsed = parseICS(text)
        let s1 = DetectedSemester(term: .S1, year: 2026, courseCount: 1, classCount: 2)

        let result = events(in: s1, from: parsed)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.map { $0.uid }, ["a", "b"])
    }
}
