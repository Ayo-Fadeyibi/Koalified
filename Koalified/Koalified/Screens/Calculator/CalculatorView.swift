//
//  CalculatorView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI
import SwiftData

/// The Calculator tab. Currently a placeholder: shows the empty state, or a "Calculator" label.
/// (Its empty check still uses sample data rather than real courses.)
struct CalculatorView: View {
    @Query private var courses: [Course]
    
    var body: some View {
        
        if courses.isEmpty {
            CalculatorEmptyView()
        }else {
            CalculatorContent()
        }
        
    }
}

#Preview {
    CalculatorView()
}
