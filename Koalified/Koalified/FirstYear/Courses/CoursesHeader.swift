//
//  CoursesHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

/// Title and subtitle at the top of the Courses tab.
struct CoursesHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Courses")
                .primaryTextStyling()
            
            Text("Courses by semester · Koalified")
                .secondaryTextStyling()
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CoursesHeader()
}
