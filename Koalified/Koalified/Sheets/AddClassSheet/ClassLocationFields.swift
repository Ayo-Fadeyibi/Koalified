//
//  ClassLocationFields.swift
//  Koalified
//

import SwiftUI

/// The "Building" and "Room" text fields shared by the add and edit class sheets.
struct ClassLocationFields: View {
    @Binding var building: String
    @Binding var room: String

    @FocusState private var focused: Field?

    private enum Field { case building, room }

    var body: some View {
        VStack(alignment: .leading) {
            field("Building", prompt: "Building, e.g. Priestley", text: $building, focus: .building)
            field("Room", prompt: "Room, e.g. 03-318", text: $room, focus: .room)
        }
    }

    private func field(_ title: LocalizedStringKey, prompt: LocalizedStringKey,
                       text: Binding<String>, focus: Field) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .boldSecondaryTextStyling()

            HStack(spacing: 10) {
                TextField(prompt, text: text)
                    .font(.fredoka(.body, .medium))
                    .foregroundStyle(Color.textPrimary)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($focused, equals: focus)

                if !text.wrappedValue.isEmpty {
                    ClearFieldButton { text.wrappedValue = "" }
                }
            }
            .textFieldStyling(isFocused: focused == focus)
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    @Previewable @State var building = "Priestley"
    @Previewable @State var room = ""
    ClassLocationFields(building: $building, room: $room)
        .padding()
}
