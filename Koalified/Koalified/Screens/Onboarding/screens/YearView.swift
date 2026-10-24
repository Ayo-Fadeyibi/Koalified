import SwiftUI

struct YearView: View {
    let years = [
        "1st year",
        "2nd year",
        "3rd year",
        "4th year or later",
        "Postgraduate"
    ]

    @AppStorage("studyYear") private var selectedYear = "1st year"

    // Tells the flow which year was chosen, so it can decide what comes next
    let onNext: (_ isFirstYear: Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 2 of 3")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)
            Text("What year are you in?")
                .foregroundStyle(Color.inkPrimary)
                .fontWeight(.bold)
                .font(.largeTitle)
            Text("This helps us set up the right tips for you.")
                .font(.subheadline)
                .foregroundStyle(Color.inkSecondary)

            VStack(spacing: 8) {
                ForEach(years, id: \.self) { year in
                    Button {
                        selectedYear = year
                    } label: {
                        HStack {
                            Text(year)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color.inkPrimary)
                            Spacer()
                            if year == selectedYear {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(Color.accentText)
                            }
                        }
                        .padding(14)
                        .background(Color.surface, in: RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(year == selectedYear ? Color.inkPop : Color.cardBorder,
                                              lineWidth: year == selectedYear ? 2 : 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                onNext(selectedYear == "1st year")
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    YearView(onNext: { _ in })
}
