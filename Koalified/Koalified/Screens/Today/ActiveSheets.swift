//
//  ActiveSheets.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 19/11/2026.
//

import Foundation

enum ActiveSheet: Identifiable {
    case importTimetable, addMenu, addClass, addDeadline, addWidget
    var id: Self { self }
}
