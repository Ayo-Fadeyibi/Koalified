import SwiftUI

/// Onboarding screen asking where the user studies. Only UQ is available for now;
/// other universities are listed (disabled) as future additions.
struct UniversityView: View {
    /// Text typed in the search field (not used for filtering yet).
    @State private var universityName = ""
    @State private var isUQSelected = true
    /// Whether the search field has focus; used to highlight its border.
    @FocusState private var isTextInputFocused: Bool

    /// Universities planned for later.
    let universityList = [
        "Queensland University of Technology",
        "Griffith University",
        "Other"
    ]
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Heading
            VStack(alignment: .leading, spacing: 8) {
                Text("Where do you study?")
                    .primaryTextStyling()
                Text("Helps organise your timetable and grades.")
                    .secondaryTextStyling()
            }
            .padding(.bottom, 20)

            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.inkSecondary)
                TextField("Search or enter university", text: $universityName)
                    .focused($isTextInputFocused)
            }
            .boxStyling(bgColor: Color.surface, cRadius:  Layout.radiusSmall, sColor: isTextInputFocused ? Color.inkPop : Color.cardBorder, lWidth: isTextInputFocused ? 2 : 1)

            // Available now
            sectionLabel("AVAILABLE NOW")

            Button {
                isUQSelected = true
            } label: {
                HStack {
                    Text("The University of Queensland")
                        .secondaryTextStyling()
                    Spacer()
                    if isUQSelected {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.accentText)
                    }
                }
                .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: isUQSelected ? Color.inkPop : Color.cardBorder, lWidth: isUQSelected ? 2 : 1)
            }
            .buttonStyle(.plain)

            // Future
            sectionLabel("FUTURE ADDITION")

            VStack(spacing: 8) {
                ForEach(universityList, id: \.self) { uni in
                    Text(uni)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.cardBorder.opacity(0.5),
                                    in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                }
            }

            Spacer()

            // Bottom
            PrimaryButton(title: "Continue", action: onNext)
                .disabled(!isUQSelected)
                .opacity(isUQSelected ? 1 : 0.5)
                .padding(.bottom, 12)

            Text("Koalified is independent. It is not an official UQ app and is not affiliated with, endorsed by, or operated by The University of Queensland.")
                .font(.caption)
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .mainContainerStyling()
    }

    // Small label used above each section
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(Color.inkSecondary)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

#Preview {
    UniversityView(onNext: {})
}
