import SwiftUI

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var showAddMenu = false
    /// Whether Today shows the calendar instead of the agenda.
    @State private var showCalendar = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                TodayHeader(showCalendar: $showCalendar)

                if SampleData.classEvents.isEmpty {
                    TodayEmptyView()
                } else {
                    TodayContentView(showCalendar: showCalendar)
                }
            }
            .padding(16)
            .background(Color.canvas)
            
            Button {
                showAddMenu = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(Color.newInk)
                    .frame(width: Layout.fabSize, height: Layout.fabSize)
                    .neoBrutalist(backgroundColor: Color.inkMint, cornerRadius: Layout.fabSize / 2)
                
            }.padding(40)
        }.sheet(isPresented: $showAddMenu) {
            AddMenuSheet(onAddClass: {}, onAddDeadline: {}, onAddWidget: {})
                .presentationDetents([.height(320)])
        }
    }
}
#Preview {
    TodayView()
}

