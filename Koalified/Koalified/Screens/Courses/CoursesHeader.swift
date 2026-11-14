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
        HStack {
            Text("Courses")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            NavigationLink {
                        ProfileView()
                    } label: {
                Image("user")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.onMint)
                    .frame(width: 48, height: 48)
                    .background(Color.mintFill, in: Circle())
                    .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 2))
            }
           
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CoursesHeader()
}
