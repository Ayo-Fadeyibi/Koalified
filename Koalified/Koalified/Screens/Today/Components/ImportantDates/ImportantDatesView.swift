//
//  SemesterDates.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

struct ImportantDatesView: View {
    
    var body: some View{
        
        
        TimelineView(.everyMinute) {
            context in
            
            let milestones = upcomingMilestones(from: Milestone.all)
            
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
                    
                    ForEach(milestones) { milestone in
                        Card{
                            
                            Badge(text: "\(milestone.title) · \(daysLabel(daysUntil(milestone.date))) LEFT", colour: Color.label)
                            
                            Text(milestone.date, format: .dateTime.day().month(.wide))
                                .primaryTextStyling()
                            
                            Text(milestone.note)
                                .secondaryTextStyling()
                                // Let the text take as many lines as it needs instead of being squeezed to one
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    }
                    
                
            }.scrollIndicators(.hidden)
                    .background(Color.screenBackground)
                
            }.padding()
                .background(Color.screenBackground)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        
        
    }
    
}

#Preview {
    ImportantDatesView()
}
