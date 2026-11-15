//
//  ProfileContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct ProfileContentView: View {
    
    @State private var showImport = false
    
    private var destination1 = [ProfileDestination.notifications, .language, .replayTour]
    private var destination2 = [ProfileDestination.removeLink, ProfileDestination.deleteData]
    private var destination3 = [ProfileDestination.addWidget, .semesterReceipt, .about, .helpFeedback]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                PlainCard {
            
                    Button {
                        print("Hello")
                    } label: {
                        HStack {
                            //Custom koala mascot will be here
                            VStack(alignment: .leading) {
                                Text("Your name")
                                    .font(.fredoka(.body, .bold))
                                    .foregroundStyle(Color.primary)
                                
                                Text("University of your choice")
                                    .secondaryTextStyling()
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.textSecondary)
                           
                        }
                    }
            
                }
                
                
              
                PlainCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your timetable")
                            .font(.fredoka(.body, .bold))
                        
                        Text("UQ timetable link · Imported today")
                            .secondaryTextStyling()
                        
                        PlainPrimaryButton(title: "Import again"){}

                        ProfileRow(destination: .reviewCourses)
                            .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                    .strokeBorder(Color.inkBorder, lineWidth: 2)
                            )

                                
                    }
                    
                }.padding(.bottom, 20)
                
                Text("Make it yours")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.textPrimary)
                
                PlainCard {
                    ForEach(destination1, id: \.self) { destination in
                        ProfileRow(destination: destination)
                        if destination != destination1.last {
                            Divider().padding(.horizontal, 14).overlay(Color.textSecondary)
                        }
                    }
                }.padding(.bottom, 20)
                
                Text("Semester Data")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.textPrimary)
                

          
                PlainCard {
                    ForEach(destination2, id: \.self) { destination in
                        ProfileRow(destination: destination)
                        if destination != destination2.last {
                            Divider().padding(.horizontal, 14).overlay(Color.textSecondary)
                        }
                    }
                }.padding(.bottom, 20)
                
                Text("More")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.textPrimary)

                PlainCard {
                    ForEach(destination3, id: \.self) { destination in
                        ProfileRow(destination: destination)
                        if destination != destination3.last {
                            Divider().padding(.horizontal, 14).overlay(Color.textSecondary)
                        }
                    }
                }.padding(.bottom, 20)
                
            }
        }.scrollIndicators(.hidden)
            .background(Color.screenBackground.ignoresSafeArea())
            .sheet(isPresented: $showImport) { ImportFlowView().sheetBorder() }
    }
}


#Preview {
    ProfileContentView()
}
