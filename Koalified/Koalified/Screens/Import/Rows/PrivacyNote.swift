//
//  PrivacyNote.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// Reassurance line shown on the import screens.
struct PrivacyNote: View {
    var body: some View {
        Text("Your file stays on this device. Nothing is uploaded or shared.")
            .font(.fredoka(.caption))
            .foregroundStyle(Color.inkSecondary)
    }
}

#Preview {
    PrivacyNote()
        .padding()
}
