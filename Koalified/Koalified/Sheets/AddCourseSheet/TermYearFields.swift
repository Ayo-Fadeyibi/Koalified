//
//  TermYearFields.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI

/// Side-by-side pickers for the semester (term) and the year (2025–2028).
struct TermYearFields: View {
    
    @Binding var term: Term
    @Binding var year: Int
    
    
    var body: some View {
        
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                
                Text("Semester")
                    .secondaryTextStyling()
                FloatingDropdown(options: Term.allCases, selection: $term, optionLabel: { $0.label })

            }
            
            VStack(alignment: .leading) {
                Text("Year")
                    .secondaryTextStyling()
                FloatingDropdown(options: Array(2025...2028), selection: $year, optionLabel: { String($0) })
            }
            
        }.zIndex(10)
        
    }
}
