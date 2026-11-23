//
//  Wallet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI
import SwiftData

struct WalletView: View {
    
    @Query private var assessments: [AssessmentItem]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            if assessments.isEmpty {
                WalletEmptyView()
            } else {
                WalletContent()
            }
            
        }
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WalletView()
    }
    .modelContainer(EmptyPreviewData.container)
}
