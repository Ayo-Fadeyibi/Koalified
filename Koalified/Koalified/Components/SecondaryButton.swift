import SwiftUI

/// Full-width outlined button for less prominent actions, shown beside a `PrimaryButton`.
struct SecondaryButton: View {
    let title: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.fredoka(.body, .semibold))
                        .foregroundStyle(Color.textPrimary)
                        
                    if let message {
                        Text(message)
                            .font(.fredoka(.caption))
                            .secondaryTextStyling()
                    }
                }

                Spacer()
                
                Text(">")
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
            }.frame(maxWidth: .infinity)
                .padding(20)
                .plainStyling()
        }.buttonStyle(.plain)
    }
}

#Preview {
    SecondaryButton(title: "Hello World", message: "Hello......") {}
        .padding()
}
