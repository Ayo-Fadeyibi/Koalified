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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Spacer()
                Button {
                    print("Skip")
                } label: {
                    Text("Skip")
                        .foregroundStyle(Color.inkPop)
                        .fontWeight(.bold)
                        .frame(minWidth: 44, minHeight: 44)   // at least a 44pt tap area
                }
            }

            Text("Where do you study?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.inkPrimary)
                .padding(.bottom, 10)

            Text("Helps organise your timetable and grades.")
                .padding(.bottom, 15)
                .foregroundStyle(Color.inkSecondary)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                TextField("Search or enter university", text: $universityName)
                    .focused($isTextInputFocused)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTextInputFocused ? Color.inkPop : Color.cardBorder, lineWidth: 2)
            }

            Text("AVAILABLE NOW")
                .fontWeight(.bold)
                .foregroundStyle(Color.inkSecondary)
                .padding(.bottom, 10)
                .padding(.top, 10)

            Button {
                isUQSelected.toggle()
            } label: {
                HStack {
                    Text("The University of Queensland")
                        .foregroundStyle(Color.inkPrimary)
                        .fontWeight(.bold)
                    Spacer()
                    if isUQSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.inkPop)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUQSelected ? Color.inkPop : Color.cardBorder, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)

            Text("FUTURE ADDITION")
                .fontWeight(.bold)
                .foregroundStyle(Color.inkSecondary)
                .padding(.bottom, 10)
                .padding(.top, 10)

            ForEach(universityList, id: \.self) { uni in
                Text(uni)
                    .foregroundStyle(Color.inkSecondary)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.cardBorder.opacity(0.5))        
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            PrimaryButton(title: "Continue") {}

            Text("Koalified is independent. It is not an official UQ app and is not affiliated with, endorsed by, or operated by The University of Queensland.")
                .foregroundStyle(Color.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.canvas)
    }
}

#Preview {
    UniversityView()
}
