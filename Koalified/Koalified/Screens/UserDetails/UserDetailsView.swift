//
//  UserDetailView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import SwiftUI
import SwiftData

struct UserDetailsView: View {
    
    @Query private var userDetail: [UserDetails]
    
    
    var body: some View {
        if let details = userDetail.first {
            UserDetailsContent(details: details)
        } else {
            UserDetailsForm()
                .mainContainerStyling()
        }
    }
}

#Preview {
    UserDetailsView()
}
