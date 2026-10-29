import SwiftUI

/// Full-width outlined button for less prominent actions, shown beside a `PrimaryButton`.
struct SecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentText)
                .frame(maxWidth: .infinity)
                .boxStyling(bgColor: Color.surface, cRadius: Layout.radiusSmall, sColor: Color.inkSecondary.opacity(0.35), lWidth: 1.5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SecondaryButton(title: "Hello World") {}
        .padding()
}
