import SwiftUI
import SwiftData

/**
 This displays the today screen by utilising two different Views: An empty screen (TodayEmptyView()) and a content screen (TodayContentView()) depending on if local storage has any courses stored
 */
struct TodayView: View {
    @State private var showAddMenu = false
    @State private var showImport = false
    
    @State private var  emptyState = false
    
    @Query private var courses: [Course]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    TodayHeader()

                    if courses.isEmpty{
                        TodayEmptyView(onImport: { showImport = true },
                        onAddManually: { showAddMenu = true })
                    } else {
                        TodayContentView()
                    }
                }
                .padding([.horizontal, .top], 16)
                .padding(.bottom, courses.isEmpty ? 16 : 0)
                // With classes, let the list run behind the tab bar instead of stopping above it.
                .ignoresSafeArea(edges: courses.isEmpty ? [] : .bottom)
                .background(Color.screenBackground)
                
                Button {
                    showAddMenu = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(Color.onMint)
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

