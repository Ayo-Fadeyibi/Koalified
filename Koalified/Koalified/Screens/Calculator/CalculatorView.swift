//
//  CalculatorView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

struct CalculatorView: View {
    
    var body: some View {
        
        if SampleData.classEvents.isEmpty {
            CalculatorEmptyView()
        }else {
            Text("Calculator")
        }
        
    }
}

#Preview {
    CalculatorView()
}
