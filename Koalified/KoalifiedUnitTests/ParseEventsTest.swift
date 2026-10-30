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
}
