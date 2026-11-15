//
//  CalculatorHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct CalculatorHeader: View {
    var body: some View {
        HStack {
            Text("Calculator")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            ProfileAvatarButton()
           
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CalculatorHeader()
}
