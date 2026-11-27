//
//  UserDetailContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 27/11/2026.
//

import SwiftUI
import SwiftData

struct UserDetailsContent: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false
    @State private var showEditDetails = false
    @State private var showUpdated = false

    let details: UserDetails

    var body: some View {

        // Scrolls so nothing gets squeezed when the card, buttons and note don't all fit above the tab
        // bar (small phones, larger text sizes).
        ScrollView {
            VStack(alignment: .leading) {

                // Same title block as the other pushed Profile screens, so the back button doesn't sit
                // directly on top of the card.
                VStack(alignment: .leading, spacing: 6) {
                    Text("My details")
                        .primaryTextStyling()

                    Text("Your personal student profile.")
                        .secondaryTextStyling()
                }
                .padding(.bottom, 16)

                StudentCard(details: details)

                Text("Tap the card to reveal the other side.")
                    .secondaryTextStyling()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)

                VStack(alignment: .leading) {
        
                    SecondaryButton(title: "Student card photo", message: "Private copy of your real card"){}

                    PlainCard(bgColor: Color.tintAmber) {
                        Text("Only you can see this. It is stored on this phone and never uploaded.")
                            .font(.fredoka(.subheadline))
                            .foregroundStyle(Color.textPrimary)
                            // Always wrap onto as many lines as it needs instead of truncating.
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image("trash")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.redFill)
                }
                .accessibilityLabel("Delete details")

                Button {
                    showEditDetails = true
                } label: {
                    Image("square-pen")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.textPrimary)
                }
                .accessibilityLabel("Edit details")
            }
        }
        .confirmationDialog("Delete your details?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                let toDelete = details      // keep a reference
                dismiss()                   // leave the screen first
                DispatchQueue.main.async {  // delete on the next tick, once it's gone
                    modelContext.delete(toDelete)
                    try? modelContext.save()
                    AppSync.dataChanged(in: modelContext)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes your name, student number, university, program and graduation date from this phone. This can't be undone.")
        }
        .sheet(isPresented: $showEditDetails) {
            UserDetailsForm(onSaved: {
                showEditDetails = false
                showUpdated = true
            })
            .sheetBorder()
        }
        .mainContainerStyling()
        // After the container styling, so the backdrop isn't inset by the screen padding.
        .PopUp(isPresented: $showUpdated, message: "Details updated successfully", image: "circle-check", colour: Color.mintFill)

    }
}

#Preview {
    UserDetailsContent(details: UserDetails(
        userName: "Alex Morgan",
        studentNumber: "s12341234",
        graduationDate: Calendar.current.date(from: DateComponents(year: 2027)),
        userUniversity: "University of Queensland",
        program: "Bachelor of Computer Science"
    ))
}
