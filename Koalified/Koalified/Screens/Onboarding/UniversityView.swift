import SwiftUI

struct UniversityView: View {
    @State private var universityName = ""
    @State private var isUQSelected = true          // renamed, starts selected like the Figma design
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
                    .focused($isTextInputFocused)           // moved onto the TextField itself
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

            // The whole row is now the button: the HStack is inside the label
            Button {
                isUQSelected.toggle()
            } label: {
                HStack {
                    Text("The University of Queensland")
                        .foregroundStyle(Color.inkPrimary)
                        .fontWeight(.bold)
                    Spacer()
                    if isUQSelected {                       // tick only exists when selected
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
            .buttonStyle(.plain)                            // no default blue tint on the label

            Text("FUTURE ADDITION")
                .fontWeight(.bold)
                .foregroundStyle(Color.inkSecondary)
                .padding(.bottom, 10)
                .padding(.top, 10)

            // Not buttons: these aren't tappable yet, so plain Text rows
            ForEach(universityList, id: \.self) { uni in
                Text(uni)
                    .foregroundStyle(Color.inkSecondary)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)  // stretch full width, text on the left
                    .padding()
                    .background(Color.cardBorder.opacity(0.5))        // muted grey fill
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            Button {
                print("Clicked")
            } label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.inkPop)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

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
