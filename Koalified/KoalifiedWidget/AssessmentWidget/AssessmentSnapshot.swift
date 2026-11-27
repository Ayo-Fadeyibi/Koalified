//
//  AssessmentSnapshot.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

//This defines what the widget needs to display
import Foundation

struct AssessmentSnapshot: Equatable {
    let courseCode: String
    let dueDate: Date
    let title: String
    let weight: Double
}
