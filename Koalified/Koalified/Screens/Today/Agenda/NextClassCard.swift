//
//  NextClassCard.swift
//  Koalified
//

import SwiftUI

/// The highlighted card at the top of the agenda: the next class, when it starts, where it is,
/// and a button for class details and directions. Shows sample data for now.
struct NextClassCard: View {
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {

                // Header row
                HStack {
                    Text("NEXT CLASS")
                        .font(.fredoka(.caption, .semibold))
                        .foregroundStyle(Color.inkSecondary)
                    Spacer()
                    Text("In 20 min")
                        .font(.fredoka(.caption, .bold))
                        .foregroundStyle(Color.accentText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .neoBrutalist(backgroundColor: Color.surface, cornerRadius: 20, shadowOffset: 2)
                }

                // Course
                Text("CSSE1001 · Lecture")
                    .font(.fredoka(.title3, .bold))
                    .foregroundStyle(Color.newInk)

                // Room and start time, each with an icon
                HStack(spacing: 16) {
                    Label("Room 50-201", systemImage: "mappin.and.ellipse")
                    Label("Starts 09:00", systemImage: "clock")
                }
                .font(.fredoka(.footnote))
                .foregroundStyle(Color.inkSecondary)

                // Button
                Button {
                    print("Class Direction")
                } label: {
                    HStack {
                        Text("Class details & directions")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.fredoka(.subheadline, .bold))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.inkPop)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSmall))
                }
            }
        }
        
    }
}

#Preview {
    NextClassCard()
        .padding()
}
