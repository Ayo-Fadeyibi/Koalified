//
//  WalletHeader.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

struct WalletHeader: View {
    var body: some View {
        HStack {
            Text("Assessment Wallet")
                .font(.fredoka(.title2, .bold))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        WalletHeader()
            .padding()
    }
}
