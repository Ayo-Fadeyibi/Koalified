import SwiftUI
import SwiftData

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var activeSheet: ActiveSheet?
    
    @State private var pendingSheet: ActiveSheet?
    
    @Query private var courses: [Course]
    
    @Binding var selectedTab: AppTab
    
    @State private var showAddedPopup = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    TodayHeader()
                    
                    if courses.isEmpty{
                        TodayEmptyView(onImport: {activeSheet = .importTimetable},
                                       onAddManually: {activeSheet = .addClass})
                    } else {
                        TodayContentView(selectedTab: $selectedTab)
                    }
                }
                .padding([.horizontal, .top], 16)
                .padding(.bottom, courses.isEmpty ? 16 : 0)
                // With classes, let the list run behind the tab bar instead of stopping above it.
                .ignoresSafeArea(edges: courses.isEmpty ? [] : .bottom)
                .background(Color.screenBackground)
                
                FloatingAddButton { activeSheet = .addMenu }
                    .padding(40)
                    .sensoryFeedback(.impact(weight: .medium), trigger: activeSheet) { _, newSheet in
                        newSheet == .addMenu
                    }
            }
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
        }
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
}

