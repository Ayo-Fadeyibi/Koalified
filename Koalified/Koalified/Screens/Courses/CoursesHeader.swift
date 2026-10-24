//
//  CoursesHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftUI

struct CoursesHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Courses")
                .font(.largeTitle.weight(.bold))
            
            Text("Courses by semester · Koalified")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CoursesHeader()
}
