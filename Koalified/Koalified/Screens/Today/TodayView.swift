import SwiftUI

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var showAddMenu = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                TodayHeader()

                if SampleData.classEvents.isEmpty {
                    TodayEmptyView()
                } else {
                    TodayContentView()
                }
            }
            .padding(16)
            .background(Color.canvas)
            
            Button {
                showAddMenu = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.inkPop, in: Capsule())
                
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

