//
//  sessionDetails.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/11/2026.
//

import SwiftUI
import SwiftData

struct SessionDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let session: ClassSession?
    
    @State private var showEditCourse = false
    @State private var showDeleteConfirm = false
    
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
                        locationTile(label: "BUILDING", value: session?.building, icon: "building.2.fill")
                        locationTile(label: "ROOM", value: session?.room, icon: "door.left.hand.open")
                    }
                }
            }


        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image("trash")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redFill)
                }
                .accessibilityLabel("Delete course")

                Button {
                    showEditCourse = true
                } label: {
                    Image("square-pen")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.textPrimary)
                }
                .accessibilityLabel("Edit course")
            }
        }
        .confirmationDialog("Delete this class?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let session {
                    modelContext.delete(session)
                }
                try? modelContext.save()
                AppSync.dataChanged(in: modelContext)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showEditCourse) {
            EditClassSheet(selectedSession: session){showUpdatedMessage = true}
                .sheetBorder()
        }
        .PopUp(isPresented: $showUpdatedMessage, message: "Class updated successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        
    }
    
    /// A small labelled tile; shows "TBA" when `value` is missing or empty.
    private func locationTile(label: String, value: String?, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.fredoka(.caption2, .bold))
                .tracking(0.5)
                .foregroundStyle(Color.textSecondary)

            Text(value.flatMap { $0.isEmpty ? nil : $0 } ?? "TBA")
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



