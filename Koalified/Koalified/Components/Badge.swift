//
//  Badge.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 18/11/2026.
//

import SwiftUI

struct Badge: View {
    let text: LocalizedStringKey
    let colour: Color
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .textCase(.uppercase)
                .font(.fredoka(.body, .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.textPrimary)
                .padding(5)
                .background(colour)
            
        }.frame(maxWidth: .infinity, alignment: .leading)
        
    }
}


#Preview {
    Badge(text: "Ayo", colour: Color.mintFill)
}
