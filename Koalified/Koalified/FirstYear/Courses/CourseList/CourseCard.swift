//
//  CourseCard.swift
//  Koalified
//

import SwiftUI

/// Card for one course in the list: a coloured code badge, title, progress bar and points earned out of 100.
/// The "On track" badge is static for now.
struct CourseCard: View {
    let code: String
    let title: String
    let accent: Color
    let earned: Double

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: 14) {
                // Badge: first four letters of the code
                Text(String(code.prefix(4)))
                    .font(.fredoka(.caption, .bold))
                    .foregroundStyle(accent)
                    .frame(width: 52, height: 52)
                    .background(accent.opacity(0.15), in: RoundedRectangle(cornerRadius: Layout.radiusSmall))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(code)
                            .font(.fredoka(.headline))
                            .foregroundStyle(accent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.inkPrimary)
                    }

                    Text(title)
                        .font(.fredoka(.footnote))
                        .foregroundStyle(Color.inkPrimary)

                    ProgressView(value: earned, total: 100)
                        .tint(accent)

                    HStack {
                        Text("\(Int(earned)) of 100 points earned so far")
                            .font(.fredoka(.caption))
                            .foregroundStyle(Color.inkSecondary)
                        Spacer()
                        Text("On track")
                            .font(.fredoka(.caption2, .semibold))
                            .foregroundStyle(Color.accentText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.accentText, lineWidth: 1)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    CourseCard(code: "CSSE1001", title: "Introduction to Software Engineering",
               accent: CourseColor.teal.color, earned: 42)
        .padding()
}
