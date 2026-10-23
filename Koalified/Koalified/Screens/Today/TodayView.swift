import SwiftUI

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

