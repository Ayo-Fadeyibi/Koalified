//
//  sessionDetails.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/11/2026.
//

import SwiftUI
import SwiftData

struct SessionDetailsView: View {
    
    let session: ClassSession?
    
    @State private var showEditCourse = false
    
    private var sessionDate: String? {
        session?.start.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }
    
    private var sessionStartTime: String? {
        session?.start.formatted(.dateTime.hour().minute())
    }
    
    private var sessionEndTime: String? {
        session?.end.formatted(.dateTime.hour().minute())
    }
    
    @State private var showUpdatedMessage = false
    
    var body: some View {

        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session?.course?.courseCode ?? "")
                    .font(.fredoka(.largeTitle, .bold))
                    .foregroundStyle(Color.textPrimary)
                if let title = session?.course?.title {
                    Text(title)
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            
            PlainCard {
                VStack(alignment: .leading, spacing: 16) {
                    // Top Row: Date + Session Type Pill
                    HStack(alignment: .center) {
                        Label(sessionDate ?? "No Date", systemImage: "calendar")
                            .font(.fredoka(.subheadline, .bold))
                            .foregroundStyle(Color.textSecondary)

                        Spacer()

                        if let typeLabel = session?.type.label {
                            PillButton(title: typeLabel, bgColor: Color.tintMint) {}
                        }
                    }

                    // Hero Time Range (using an en-dash)
                    Text("\(sessionStartTime ?? "--:--") – \(sessionEndTime ?? "--:--")")
                        .primaryTextStyling()
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                  

                    // Location Tiles: Building & Room Side-by-Side
                    HStack(spacing: 10) {
                        locationTile(
                            label: "BUILDING",
                            value: session?.building?.isEmpty == false ? session!.building! : "TBA",
                            icon: "building.2.fill"
                        )

                        locationTile(
                            label: "ROOM",
                            value: session?.room?.isEmpty == false ? session!.room! : "TBA",
                            icon: "door.left.hand.open"
                        )
                    }
                }
            }


        }
        .mainContainerStyling()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditCourse = true }
            }
        }
        .sheet(isPresented: $showEditCourse) {
            EditClassSheet(selectedSession: session){showUpdatedMessage = true}
                .sheetBorder()
        }
        .PopUp(isPresented: $showUpdatedMessage, message: "Class updated successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        
    }
    
    private func locationTile(label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.fredoka(.caption2, .bold))
                .tracking(0.5)
                .foregroundStyle(Color.textSecondary)

            Text(value)
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.inkBorder.opacity(0.35), lineWidth: 1.5)
        )
    }

}

#Preview {
    let context = PreviewData.container.mainContext
    let course = try! context
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "CSSE1001" }))
        .first!
    let start = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now)!
    let session = ClassSession(start: start,
                               end: start.addingTimeInterval(2 * 60 * 60),
                               type: .LEC,
                               room: "E302",
                               building: "Forgan Smith Building",
                               course: course)
    context.insert(session)

    return NavigationStack { SessionDetailsView(session: session) }
        .modelContainer(PreviewData.container)
}



