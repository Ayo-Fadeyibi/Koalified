//
//  WalletContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI
import SwiftData

struct WalletContent: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            WalletHeader()
            Text("Your semester. One ticket at a time.")
                .secondaryTextStyling()
            
           
        }
        .padding(.top, Layout.screenPadding)
        .mainContainerStyling()
        
    }
}


#Preview {
    WalletContent()
}
