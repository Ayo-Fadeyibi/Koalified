//
//  TodayContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/*
 This view handles and display the data stored on the local storage including lecture time, location and courses. Shows either the agenda or, when `showCalendar` is true, the calendar view
 */
struct TodayContentView: View {
    /// True to show the calendar instead of the agenda (toggled by the button in `TodayHeader`).
    let showCalendar: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !showCalendar {
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
                            .foregroundStyle(Color.inkPrimary)

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
                
                HStack (spacing: 5) {
                    Text("Today")
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.inkPrimary)
                    Text("Tue 20 Oct")
                        .foregroundStyle(Color.inkSecondary)
                }.padding(.top, 20)
                
                ForEach(SampleData.classEvents) { data in
                    Card {
                        HStack(spacing: 16) {

                            // Time column
                            VStack(alignment: .leading, spacing: 2) {
                                Text(data.start, style: .time)
                                    .font(.fredoka(.headline))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text(data.end, style: .time)
                                    .font(.fredoka(.caption))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 70, alignment: .leading)

                            Divider()
                                .frame(height: 40)
                            
                            // Course and room
                            VStack(alignment: .leading, spacing: 4) {
                                Text(data.courseCode)
                                    .font(.fredoka(.headline))
                                Label("Room \(data.room)", systemImage: "mappin.and.ellipse")
                                    .font(.fredoka(.caption))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Kind pill (Lecture, Tutorial...)
                            Text(data.kind.label)
                                .font(.fredoka(.caption, .semibold))
                                .foregroundStyle(Color.accentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .neoBrutalist(backgroundColor: Color.surface, cornerRadius: 20, shadowOffset: 2)
                        }
                    }
                }
            } else {
               CalendarTabContent()
            }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    TodayContentView(showCalendar: false)
}
