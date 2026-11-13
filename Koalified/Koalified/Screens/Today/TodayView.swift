import SwiftUI

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var showAddMenu = false
    @State private var showImport = false
    /// Whether Today shows the calendar instead of the agenda.
    @State private var showCalendar = false
    
    @State private var  emptyState = true
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    TodayHeader()

                    if emptyState{
                        TodayEmptyView(onImport: { showImport = true },
                                       onAddManually: { showAddMenu = true })
                    } else {
                        TodayContentView(showCalendar: showCalendar)
                    }
                }
                .padding(16)
                .background(Color.screenBackground)
                
                Button {
                    showAddMenu = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: Layout.fabSize, height: Layout.fabSize)
                        .neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: Layout.fabSize / 2)
                    
                }.padding(40)
            }
            .sheet(isPresented: $showImport) { ImportFlowView() }
            .sheet(isPresented: $showAddMenu) {
                AddMenuSheet(onAddClass: {}, onAddDeadline: {}, onAddWidget: {})
                    .presentationDetents([.height(320)])
            }
        }
    }
}
#Preview {
    TodayView()
}

