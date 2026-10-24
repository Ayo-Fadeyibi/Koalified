//
//  TodayContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct TodayContentView: View {
    @State private var selectedView = "Agenda"
    let options = ["Agenda", "Calendar"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Today View", selection: $selectedView) {
                ForEach (options, id: \.self) {
                    option in Text(option)
                }
            }.pickerStyle(.segmented)
                .padding(.bottom, 10)
            
            if selectedView == "Agenda" {
                Card {
                    VStack(alignment: .leading, spacing: 10) {

                        // Header row
                        HStack {
                            Text("NEXT CLASS")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.inkSecondary)
                            Spacer()
                            Text("In 20 min")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.accentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.inkPop.opacity(0.12), in: Capsule())
                        }

                        // Course
                        Text("CSSE1001 · Lecture")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.inkPrimary)

                        // Room and start time, each with an icon
                        HStack(spacing: 16) {
                            Label("Room 50-201", systemImage: "mappin.and.ellipse")
                            Label("Starts 09:00", systemImage: "clock")
                        }
                        .font(.footnote)
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
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.inkPop)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                
                HStack (spacing: 5) {
                    Text("Today")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.inkPrimary)
                    Text("Tue 20 Oct")
                        .foregroundStyle(Color.inkSecondary)
                }
                
                ForEach(SampleData.classEvents) { data in
                    Card {
                        HStack(spacing: 16) {

                            // Time column
                            VStack(alignment: .leading, spacing: 2) {
                                Text(data.start, style: .time)
                                    .font(.headline)
                                Text(data.end, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 70, alignment: .leading)

                            Divider()
                                .frame(height: 40)
                            
                            // Course and room
                            VStack(alignment: .leading, spacing: 4) {
                                Text(data.courseCode)
                                    .font(.headline)
                                Label("Room \(data.room)", systemImage: "mappin.and.ellipse")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            // Kind pill (Lecture, Tutorial...)
                            Text(data.kind)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.inkPop.opacity(0.12), in: Capsule())
                        }
                    }
                }
            } else {
               Text("Calendar")
            }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    TodayContentView()
}
