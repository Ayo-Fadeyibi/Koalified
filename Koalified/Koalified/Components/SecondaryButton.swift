import SwiftUI

struct SecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surface, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                .overlay {
                    RoundedRectangle(cornerRadius: Layout.radiusSmall)
                        .strokeBorder(Color.inkSecondary.opacity(0.35), lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SecondaryButton(title: "Hello World") {}
        .padding()
}
