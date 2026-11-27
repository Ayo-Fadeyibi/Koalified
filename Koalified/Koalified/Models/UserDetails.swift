//
//  UserDetails.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/11/2026.
//

import Foundation
import SwiftData

@Model
final class UserDetails{
    var userName: String?
    var studentNumber: String?
    var graduationDate: Date?
    var userUniversity: String?
    /// Degree program, e.g. "Bachelor of Computer Science".
    var program: String?

    init(userName: String? = nil, studentNumber: String? = nil, graduationDate: Date? = nil, userUniversity: String? = nil, program: String? = nil) {
        self.userName = userName
        self.studentNumber = studentNumber
        self.graduationDate = graduationDate
        self.userUniversity = userUniversity
        self.program = program
    }

}
