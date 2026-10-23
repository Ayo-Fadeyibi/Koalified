import SwiftUI

struct UniversityView: View {
    @State private var universityName = ""
    @State private var isUQSelected = true
    @FocusState private var isTextInputFocused: Bool

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
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color.inkPrimary)
                Text("Helps organise your timetable and grades.")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
            }
            .padding(.bottom, 20)

            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.inkSecondary)
                TextField("Search or enter university", text: $universityName)
                    .focused($isTextInputFocused)
            }
            .padding(14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isTextInputFocused ? Color.inkPop : Color.cardBorder,
                                  lineWidth: isTextInputFocused ? 2 : 1)
            }

            // Available now
            sectionLabel("AVAILABLE NOW")

            Button {
                isUQSelected = true
            } label: {
                HStack {
                    Text("The University of Queensland")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.inkPrimary)
                    Spacer()
                    if isUQSelected {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.inkPop)
                    }
                }
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isUQSelected ? Color.inkPop : Color.cardBorder,
                                      lineWidth: isUQSelected ? 2 : 1)
                }
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
                                    in: RoundedRectangle(cornerRadius: 12))
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
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
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
