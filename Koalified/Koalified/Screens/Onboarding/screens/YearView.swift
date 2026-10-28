import SwiftUI

/// Onboarding step 2: choose the year of study. First-years are sent on to the timetable help screen.
struct YearView: View {
    /// The options shown, in order.
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
                .secondaryTextStyling()
            Text("What year are you in?")
                .primaryTextStyling()
            Text("This helps us set up the right tips for you.")
                .tinyText()

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
                        .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: year == selectedYear ? Color.inkPop : Color.cardBorder, lWidth: year == selectedYear ? 2 : 1)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                onNext(selectedYear == "1st year")
            }
        }
        .mainContainerStyling()
    }
}

#Preview {
    YearView(onNext: { _ in })
}
