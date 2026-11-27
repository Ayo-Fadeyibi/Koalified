import SwiftUI
import SwiftData

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var activeSheet: ActiveSheet?

    @Query private var courses: [Course]

    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    TodayHeader(activeSheet: $activeSheet)
                    
                    if courses.isEmpty{
                        TodayEmptyView(onImport: {activeSheet = .importTimetable},
                                       onAddManually: {activeSheet = .addClass})
                    } else {
                        TodayContentView(selectedTab: $selectedTab)
                    }
                }
                .padding([.horizontal, .top], Layout.screenPadding)
                .padding(.bottom, courses.isEmpty ? 16 : 0)
                // With classes, let the list run behind the tab bar instead of stopping above it.
                .ignoresSafeArea(edges: courses.isEmpty ? [] : .bottom)
                .background(Color.screenBackground)
                
                
            }
            .addMenuSheets($activeSheet)
            .toolbar(.hidden, for: .navigationBar)
            .profileDestination()
        }
    }
}

#Preview {
    TodayView(selectedTab: .constant(.today))
}

