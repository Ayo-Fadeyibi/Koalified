import SwiftUI
import SwiftData
import WidgetKit

/// Onboarding screen asking for the student's name and university.
struct UserDetailsView: View {
    
    @Query private var userDetail: [UserDetails]
    
    private var content: UserDetails? { userDetail.first }
    
    
    @State private var userName = ""
    @State private var universityName = "University of Queensland"
    @State private var isUQSelected = true
    @FocusState private var isTextInputFocused: Bool
    
    @State private var showAdded = false
    

    private var trimmedName: String {
        userName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        isUQSelected && !trimmedName.isEmpty
    }
    
    private let universityList = [
        "University of Queensland",
        "Queensland University of Technology"
    ]
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Heading
            VStack(alignment: .leading, spacing: 6) {
                Text("Make it yours")
                    .primaryTextStyling()

                Text("Tell us what to call you so we can personalise your dashboard.")
                    .secondaryTextStyling()
            }
            .padding(.bottom, 24)

            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME")
                    .font(.fredoka(.caption, .bold))
                    .tracking(0.6)
                    .foregroundStyle(Color.textSecondary)

                HStack(spacing: 10) {
                    TextField("e.g. Alex", text:$userName)
                        .font(.fredoka(.body, .medium))
                        .foregroundStyle(Color.textPrimary)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .focused($isTextInputFocused)

                    if !userName.isEmpty {
                        Button {
                            userName = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .textFieldStyling(isFocused: isTextInputFocused)
            }
            .padding(.bottom, 24)

            // University Selection
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("UNIVERSITY")
                        .font(.fredoka(.caption, .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.textSecondary)

                    Spacer()

                    Text("MORE SOON")
                        .font(.fredoka(.caption2, .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.cardSurface, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.inkBorder.opacity(0.35), lineWidth: 1))
                }
                
                ForEach(universityList, id: \.self) { university in
                    
                    SelectableRow(isSelected: universityName == university, action: {
                        isTextInputFocused = false
                        universityName = university
                    }) {
                       
                        HStack(spacing: 12) {
                            VStack(alignment: .leading) {
                                Text(university)
                                    .font(.fredoka(.body, .bold))
                                    .foregroundStyle(Color.textPrimary)

                                Text("St Lucia · Gatton · Herston")
                                    .font(.fredoka(.caption, .medium))
                                    .foregroundStyle(Color.textSecondary)
                            }

                        }
                        
                    }
               
                }
               
            }.padding(.bottom, 250)
            

            // Bottom CTA & Disclaimer
            VStack(spacing: 12) {
                PrimaryButton(title: "Save") {
                    isTextInputFocused = false
                    save()
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)

                Text("Koalified is independent. It is not an official UQ app and is not affiliated with, endorsed by, or operated by The University of Queensland.")
                    .font(.fredoka(.caption))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .mainContainerStyling()
        .contentShape(Rectangle())
        .onTapGesture {
            isTextInputFocused = false
        }
        .onAppear {
            // @Query isn't available during property initialisation, so prefill here.
            if userName.isEmpty, let savedName = content?.userName {
                userName = savedName
            }
            if let savedUniversity = content?.userUniversity {
                universityName = savedUniversity
            }
        }
        .PopUp(isPresented: $showAdded, message: "Details added successfully", image: "circle-check", colour: Color.mintFill)
    }
    
    
    /// Updates the existing details record, or creates one on first save.
    private func save() {
        if let content {
            content.userName = trimmedName
            content.userUniversity = universityName
        } else {
            modelContext.insert(UserDetails(userName: trimmedName, userUniversity: universityName))
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        showAdded = true
    }
}

#Preview {
    UserDetailsView()
}
