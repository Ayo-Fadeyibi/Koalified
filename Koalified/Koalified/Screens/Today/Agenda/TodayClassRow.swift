//
//  TodayClassRow.swift
//  Koalified
//

import SwiftUI

/// One class in today's list: start and end time, course code and room, and a pill for the class type.
struct TodayClassRow: View {
    let event: ClassEvent

    var body: some View {
        Card {
            HStack(spacing: 16) {

                // Time column
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.start, style: .time)
                        .font(.fredoka(.headline))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(event.end, style: .time)
                        .font(.fredoka(.caption))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 70, alignment: .leading)

                Divider()
                    .frame(height: 40)
                
                // Course and room
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.courseCode)
                        .font(.fredoka(.headline))
                    Label("Room \(event.room)", systemImage: "mappin.and.ellipse")
                        .font(.fredoka(.caption))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Kind pill (Lecture, Tutorial...)
                Text(event.kind.label)
                    .font(.fredoka(.caption, .semibold))
                    .foregroundStyle(Color.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: 20, shadowOffset: 2)
            }
        }
    }
}

#Preview {
    TodayClassRow(event: SampleData.classEvents[0])
        .padding()
}
