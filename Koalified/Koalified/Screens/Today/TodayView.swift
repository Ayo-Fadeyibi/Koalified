import SwiftUI
import Playgrounds

struct TodayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.inkPrimary)
            Text("\(Date.now, format: .dateTime.weekday().day().month(.wide).year()) · Koalified")
                .foregroundStyle(Color.inkSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    TodayView()
}

