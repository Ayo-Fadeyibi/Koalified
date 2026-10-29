//
//  ParseEvent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 29/10/2026.
//

import Foundation

struct ParsedEvent {
    let uid: String
    let courseCode: String
    let title: String
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

