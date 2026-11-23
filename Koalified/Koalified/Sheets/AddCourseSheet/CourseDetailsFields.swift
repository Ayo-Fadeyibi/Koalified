import SwiftUI

struct CourseDetailsFields: View {
    @Binding var code: String
    @Binding var name: String
    @FocusState private var focused: Field?

    private enum Field { case code, name }

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Course code")
                    .boldSecondaryTextStyling()

                HStack(spacing: 10) {
                    TextField("e.g. CSSE1001", text: $code)
                        .focused($focused, equals: .code)
                        .textInputAutocapitalization(.characters)
                        .submitLabel(.next)
                        .onSubmit { focused = .name }

                    if !code.isEmpty {
                        clearButton(label: "Clear course code") { code = "" }
                    }
                }
                .textFieldStyling(isFocused: focused == .code)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Course name (optional)")
                    .boldSecondaryTextStyling()

                HStack(spacing: 10) {
                    TextField("Introduction to Software Engineering", text: $name)
                        .focused($focused, equals: .name)

                    if !name.isEmpty {
                        clearButton(label: "Clear course name") { name = "" }
                    }
                }
                .textFieldStyling(isFocused: focused == .name)
            }
        }
    }

    private func clearButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
