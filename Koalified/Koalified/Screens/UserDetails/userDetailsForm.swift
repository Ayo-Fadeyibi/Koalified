import SwiftUI
import SwiftData
import WidgetKit

/// Onboarding screen asking for the student's name and university.
struct UserDetailsForm: View {
    
    @Query private var userDetail: [UserDetails]
    
    private var content: UserDetails? { userDetail.first }
    
    
    @State private var userName = ""
    @State private var universityName = "University of Queensland"
    @State private var studentNumber = ""
    @State private var isUQSelected = true
    @State private var graduationDate: Date = .now
    
    @FocusState private var isTextInputFocused: Bool
    @FocusState private var isStudentNumberFocused: Bool
    
    @State private var showAdded = false

    /// Called after saving. When set (e.g. editing from a sheet), the caller closes the form and
    /// shows its own confirmation instead of this view's popup.
    var onSaved: (() -> Void)? = nil

    private var trimmedName: String {
        userName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        isUQSelected && !trimmedName.isEmpty
    }
    
    private let universityList = [
        "University of Queensland",
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
                    // Wrap instead of truncating.
                    .fixedSize(horizontal: false, vertical: true)
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
                        ClearFieldButton { userName = "" }
                    }
                }
                .textFieldStyling(isFocused: isTextInputFocused)
            }
            .padding(.bottom, 24)
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR STUDENT NUMBER")
                        .font(.fredoka(.caption, .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.textSecondary)

                    HStack(spacing: 10) {
                        TextField("e.g. s12345678", text:$studentNumber)
                            .font(.fredoka(.body, .medium))
                            .foregroundStyle(Color.textPrimary)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .focused($isStudentNumberFocused)

                        if !studentNumber.isEmpty {
                            ClearFieldButton { studentNumber = "" }
                        }
                    }
                    .textFieldStyling(isFocused: isStudentNumberFocused)
                }
                
                
                Spacer()
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("GRADUATION DATE")
                        .font(.fredoka(.caption, .bold))
                        .tracking(0.6)
                        .foregroundStyle(Color.textSecondary)
                    
                    PopoverDatePicker(selection: $graduationDate)
                }
                
            }.padding(.bottom, 24)

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
               
            }

            // Pushes the button to the bottom without forcing the form taller than the screen.
            Spacer(minLength: 24)

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
        .padding(.top)
        .padding(.horizontal, Layout.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            
            if let savedStudentNumber = content?.studentNumber {
                studentNumber = savedStudentNumber
            }
            
            if let savedGraduationDate = content?.graduationDate{
                graduationDate = savedGraduationDate
            }
        }
        .PopUp(isPresented: $showAdded, message: "Details added successfully", image: "circle-check", colour: Color.mintFill)
    }
    
    
    /// Updates the existing details record, or creates one on first save.
    private func save() {
        if let content {
            content.userName = trimmedName
            content.studentNumber = studentNumber
            content.graduationDate = graduationDate
            content.userUniversity = universityName
        } else {
            modelContext.insert(UserDetails(userName: trimmedName,studentNumber: studentNumber, graduationDate: graduationDate, userUniversity: universityName))
        }

        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()

        if let onSaved {
            onSaved()
        } else {
            showAdded = true
        }
    }
}

#Preview {
    UserDetailsForm()
}
