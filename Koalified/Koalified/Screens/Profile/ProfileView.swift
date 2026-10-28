//
//  ProfileView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// The Profile tab. Placeholder for now.
struct ProfileView: View {
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile")
                    .primaryTextStyling()
                
                Text("Account and settings · Koalified")
                    .secondaryTextStyling()
                
                Card {
                    
                    VStack {
                        HStack (spacing: 12) {
                            Text("Image")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                                .padding(Layout.screenPadding)
                                .background(Color.inkPop, in: Circle())
                            
                            VStack(alignment: .leading) {
                                Text("Your name")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primary)
                                
                                Text("University of Queensland · BE (Honours)")
                                    .secondaryTextStyling()
                            }
                        }
                        
                        SecondaryButton(title: "Customise Koala"){}
                    }
                }
              
                Card {
                    Text("Upcoming Features")
                        .foregroundStyle(Color.inkPop)
                        .fontWeight(.bold)
                    
                    Text("Study coach, cloud sync and social features are planned for later. Your manual planner works without them.")
                        .secondaryTextStyling()
                    
                    SecondaryButton(title: "See what's coming"){}
                }
                
                Card {
                    ForEach(SampleData.profileLinks, id: \.self) {link in
                        Button {
                            
                        } label: {
                            Text(link)
                                .secondaryTextStyling()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.inkSecondary)
                        }
                        if link != SampleData.profileLinks.last {
                            Divider().padding(.horizontal, 14)
                        }
                    }
                }
                
            }.mainContainerStyling()
        }
    }
}

#Preview {
    ProfileView()
}
