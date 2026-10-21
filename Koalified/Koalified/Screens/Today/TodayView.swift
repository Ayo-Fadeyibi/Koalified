import SwiftUI

struct TodayView: View {
    @State private var selectedView = "Agenda"
    let options = ["Agenda", "Calendar"]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.inkPrimary)
            Text("\(Date.now, format: .dateTime.weekday().day().month(.wide).year()) · Koalified")
                .foregroundStyle(Color.inkSecondary)
                .padding(.bottom, 10)
            
            Picker("Today View", selection: $selectedView) {
                ForEach (options, id: \.self) {
                    option in Text(option)
                }
            }.pickerStyle(.segmented)
            
            if selectedView == "Agenda" {
                Text("Agenda")
            } else {
               Text("Calendar")
            }
                
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    TodayView()
}

