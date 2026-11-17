//
//  SemesterDates.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

struct ImportantDatesView: View {
    
    var body: some View{
        
        
        VStack(alignment: .leading, spacing: 30) {
            Text("Semester Dates")
                .primaryTextStyling()
            
            Text("Know your next milestone")
                .font(.fredoka(.body, .bold))
            
            Link(destination: URL(string: "https://about.uq.edu.au/academic-calendar")!) {
                HStack(spacing: 8) {
                    Text("Check official semester dates")
                        .font(.fredoka(.body, .bold))
                }
                .foregroundStyle(Color.onMint)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mintFill, in: RoundedRectangle(cornerRadius: Layout.radiusLarge))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusLarge)
                        .strokeBorder(Color.inkBorder, lineWidth: 2)
                )
            }.frame(maxWidth: .infinity)
            
            ScrollView {
                
            Card{
                Text("CENSUS DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
                    // Let the text take as many lines as it needs instead of being squeezed to one
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Card{
                Text("MID SEM BREAK  DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
                    // Let the text take as many lines as it needs instead of being squeezed to one
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Card{
                Text("CENSUS DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
                    // Let the text take as many lines as it needs instead of being squeezed to one
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.scrollIndicators(.hidden)
                .background(Color.screenBackground)
            
        }.padding()
            .background(Color.screenBackground)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        
        
    }
    
}

#Preview {
    ImportantDatesView()
}
