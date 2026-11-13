//
//  ProfileView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// The Profile tab. Placeholder for now.
struct ProfileView: View {
    @State private var showImport = false
    @State private var showComic = false

    var body: some View {
        NavigationStack {
            ScrollView {
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
                                    .font(.fredoka(.body, .bold))
                                    .padding(Layout.screenPadding)
                                    .background(Color.greenDeep, in: Circle())
                                
                                VStack(alignment: .leading) {
                                    Text("Your name")
                                        .font(.fredoka(.body, .bold))
                                        .foregroundStyle(Color.primary)
                                    
                                    Text("University of Queensland · BE (Honours)")
                                        .secondaryTextStyling()
                                }
                            }
                            
                            SecondaryButton(title: "Customise Koala"){}
                            SecondaryButton(title: "Import timetable (.ics)") { showImport = true }
                        }
                    }
                  
                    Card {
                        HStack {
                            Image("sparkles")
                                .foregroundStyle(Color.greenDeep)
                            Text("Upcoming Features")
                                .foregroundStyle(Color.greenDeep)
                                .font(.fredoka(.body, .bold))
                        }
                        
                        Text("Study coach, cloud sync and social features are planned for later. Your manual planner works without them.")
                            .secondaryTextStyling()
                        
                        TertiaryButton(title: "See what's coming"){}
                    }
                    
                    // The comic used to open the app; it now lives here.
                    Card {
                        Button {
                            showComic = true
                        } label: {
                            Text("The Koalified story")
                                .secondaryTextStyling()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.textSecondary)
                        }.padding(10)
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
                                    .foregroundStyle(Color.textSecondary)
                            }.padding(10)
                            if link != SampleData.profileLinks.last {
                                Divider().padding(.horizontal, 14)
                            }
                        }
                    }
                    
                }.mainContainerStyling()
            }.scrollIndicators(.hidden)
                .background(Color.screenBackground.ignoresSafeArea())
        }
        .sheet(isPresented: $showImport) { ImportFlowView() }
        .fullScreenCover(isPresented: $showComic) {
            OnboardingComicView(onFinish: { showComic = false }, finishTitle: "Done")
        }
    }
}

#Preview {
    ProfileView()
}
