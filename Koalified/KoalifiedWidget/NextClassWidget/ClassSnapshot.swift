//
//  ClassSnapshot.swift.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 18/11/2026.
//

//This defines what the widget needs to display
import Foundation

struct ClassSnapshot: Equatable {
    let courseCode: String
    let typeLabel: String
    let start: Date
    let end: Date
    let room: String?
    let building: String?
}
