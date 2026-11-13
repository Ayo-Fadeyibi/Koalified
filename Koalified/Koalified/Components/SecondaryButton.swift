import SwiftUI

/// Full-width outlined button for less prominent actions, shown beside a `PrimaryButton`.
struct SecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.fredoka(.body, .semibold))
                    .foregroundStyle(Color.textPrimary)
                    
                
                Spacer()
                
                Text(">")
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
            }.frame(maxWidth: .infinity)
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(Color.black, lineWidth: 2)
                )
        }.buttonStyle(.plain)
    }
}

#Preview {
    SecondaryButton(title: "Hello World") {}
        .padding()
}
