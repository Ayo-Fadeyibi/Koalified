//
//  CalendarTabContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

/// The Timetable tab: a fixed header above a scrolling weekly grid of classes (or a single day) and an add-class button.
struct CalendarTabContent: View {
    
    @State private var activeSheet: ActiveSheet?
    @State private var pendingSheet: ActiveSheet?
    @State private var showAddedPopup = false
    
    var body: some View {
        NavigationStack {
            // The header and week controls stay put; only the timetable and button below them scroll.
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    CalendarHeader()
                        .padding(.bottom, 10)

                    // Week controls are fixed; the grid and the button scroll beneath them.
                    WeekGridView()
                }
                .padding([.horizontal, .top], Layout.screenPadding)
                // Let the scrolling content run behind the tab bar instead of stopping above it.
                // Applied to the content only, so the button stays above the tab bar.
                .ignoresSafeArea(edges: .bottom)
                .background(Color.screenBackground)

                FloatingAddButton { activeSheet = .addMenu }
                    .padding(40)
                    .sensoryFeedback(.impact(weight: .medium), trigger: activeSheet) { _, newSheet in
                        newSheet == .addMenu
                    }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $activeSheet, onDismiss: { activeSheet = pendingSheet; pendingSheet = nil }){ sheet in
                switch sheet {
                case .importTimetable:
                    ImportLinkSheet()
                        .sheetBorder()
                    
                case .addMenu:
                    // your AddMenuSheet, with its .sheetBorder and .presentationDetents
                    AddMenuSheet(
                        onAddClass: {pendingSheet = .addClass; activeSheet = nil },
                        onAddDeadline: {pendingSheet = .addDeadline; activeSheet = nil },
                        onAddWidget: {pendingSheet = .addWidget; activeSheet = nil }
                    )
                    .sheetBorder(topInset: 0.4)
                    .presentationDetents([.height(350)])
                    
                case .addClass:
                    AddClassSheet(onAdded: { showAddedPopup = true })
                        .sheetBorder()
                    
                case .addDeadline:
                    Text("Add deadline")
                    
                case .addWidget:
                    Text("Add widget")
                }
            }
            .PopUp(isPresented: $showAddedPopup, message: "Class added", image: "circle-check", colour: .accent)
            .profileDestination()
            .navigationDestination(for: ClassSession.self) { session in
                SessionDetailsView(session: session)
                    
            }
        }
    }
}

#Preview {
    CalendarTabContent()
        .modelContainer(PreviewData.container)
}
