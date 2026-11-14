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
            
            PrimaryButton(title: "Check official semester dates"){}
                .frame(width: 400)
            
            Card{
                Text("CENSUS DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
            }
            
            Card{
                Text("MID SEM BREAK  DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
            }
            
            Card{
                Text("CENSUS DATE · 9 DAYS LEFT")
                    .font(.fredoka(.body, .bold))
                    .padding(5)
                    .background(Color.label)
                
                Text("29 October")
                    .primaryTextStyling()
                
                Text("Check the last day to withdraw without course fees for your semester.")
                    .secondaryTextStyling()
            }
        }.padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.screenBackground)
        
    }
    
}

#Preview {
    ImportantDatesView()
}
