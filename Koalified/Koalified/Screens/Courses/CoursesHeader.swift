//
//  CoursesHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

/// Title and subtitle at the top of the Courses tab.
struct CoursesHeader: View {
    
    @Binding var showAddCourse: Bool
    
    var body: some View {
        HStack {
            Text("Courses")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            HeaderAddButton(accessibilityLabel: "Add a course") {
                showAddCourse = true
            }.sensoryFeedback(.impact(weight: .medium), trigger: showAddCourse) { _, newValue in
                newValue
            }
    
            
            ProfileAvatarButton()
           
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CoursesHeader(showAddCourse: .constant(false))
}
