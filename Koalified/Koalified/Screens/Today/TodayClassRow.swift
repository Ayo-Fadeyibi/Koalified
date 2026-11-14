//
//  TodayClassRow.swift
//  Koalified
//

import SwiftUI

/// One class in today's list: start and end time, course code and room, and a pill for the class type.
struct TodayClassRow: View {
    let event: ClassSession

    var body: some View {
        Card {
            HStack(spacing: 16) {

                // Time column
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.start.formatted(date: .omitted, time: .shortened))
                        .font(.fredoka(.headline))
                    Text(event.end.formatted(date: .omitted, time: .shortened))
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .fixedSize()

                Divider()
                    .frame(height: 40)
                
                // Course and room
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.course?.courseCode ?? "")
                        .font(.fredoka(.headline))
                    Label("Room \(event.room)", systemImage: "mappin.and.ellipse")
                        .font(.fredoka(.caption))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Kind pill (Lecture, Tutorial...)
                Text(event.type.label)
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
    let start = Date().addingTimeInterval(20 * 60)
    let session = ClassSession(start: start,
                               end: start.addingTimeInterval(60 * 60),
                               type: .LEC,
                               room: "50-201",
                               building: "Hawken Engineering Building"
    )
    TodayClassRow(event: session)
        .padding()
}
