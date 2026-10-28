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
            FormField("Semester") {
                Picker("Semester", selection: $term) {
                    ForEach(Term.allCases, id: \.self) { term in
                        Text(term.label).tag(term)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(Color.inkPrimary)
            }

            FormField("Year") {
                Picker("Year", selection: $year) {
                    ForEach(2025...2028, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(Color.inkPrimary)
            }
        }
    }
}
