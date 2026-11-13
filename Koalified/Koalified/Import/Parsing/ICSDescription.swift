//
//  ICSDescription.swift
//  Koalified
//
//  Step 2: breaks an event's DESCRIPTION text into course, term, year, campus and so on.
//

import Foundation

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
