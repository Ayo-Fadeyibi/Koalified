//
//  SemesterRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI

/// One tickable semester in the "Which semester?" list.
struct SemesterRow: View {
    let title: String
    let subtitle: String
    let status: String?
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                checkbox

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.fredoka(.subheadline, .semibold))
                            .foregroundStyle(Color.textPrimary)
                        if let status {
                            StatusTag(text: status, color: status == "Past" ? Color.textSecondary : Color.accent)
                        }
                    }
                    Text(subtitle)
                        .font(.fredoka(.caption))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var checkbox: some View {
        Color.clear
            .frame(width: 22, height: 22)
            .neoBrutalist(backgroundColor: isOn ? Color.tintMint : Color.cardSurface, cornerRadius: 6, borderWidth: 2, shadowOffset: 2)
            .overlay {
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .frame(width: 22, height: 22)
    }
}

#Preview {
    Card {
        SemesterRow(title: "Semester 2, 2026", subtitle: "4 courses · 11 classes", status: "Current", isOn: true) {}
        Divider()
        SemesterRow(title: "Semester 1, 2026", subtitle: "4 courses · 12 classes", status: "Past", isOn: false) {}
    }
    .padding()
    .background(Color.screenBackground)
}
