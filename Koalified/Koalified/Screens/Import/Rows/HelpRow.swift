//
//  HelpRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// A short tip with a bold title and a sentence under it.
struct HelpRow: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.fredoka(.subheadline, .semibold))
                .foregroundStyle(Color.textPrimary)
            Text(text)
                .font(.fredoka(.caption))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    Card {
        HelpRow(title: "Check the file type", text: "Use the .ics calendar file you downloaded from your timetable.")
    }
    .padding()
    .background(Color.screenBackground)
}
