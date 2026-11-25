//
//  ProfileHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct ProfileHeader: View {
    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading) {
                Text("Profile")
                    .primaryTextStyling()
                
                Text("Account and settings · Koalified")
                    .secondaryTextStyling()
            }
            
            Spacer()
            
            ThemeToggleButton()
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom,  20)
    }
}

#Preview {
    ProfileHeader()
}
