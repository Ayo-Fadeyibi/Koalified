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
    var userUniversity: String?
    
    init(userName: String? = nil, userUniversity: String? = nil) {
        self.userName = userName
        self.userUniversity = userUniversity
    }

}
