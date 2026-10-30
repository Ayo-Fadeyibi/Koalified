//
//  ParseEvent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 29/10/2026.
//

import Foundation

// The struct that contains all the values to be extracted from the .ics file
struct ParsedEvent {
    let uid: String
    let courseCode: String
    let title: String?
    let start: Date
    let end: Date
    let room: String?
    let term: Term?
    let year: Int?
    let type: SessionType?
    let typeCode: String?
    let staff: String?
    let campus: String?
    let classNumber: String?
    let isClashable: Bool
    let isRecorded: Bool
}

//Struct that contains all the values to be extracted from the description
struct DescriptionInfo {
    let title: String?
    let courseCode: String
    let term: Term?
    let year: Int?
    let campus: String?
    let classNumber: String?
    let mode: String?
    let typeCode: String?
    let staffName: String?
    let isClashable: Bool
    let isRecorded: Bool
}
