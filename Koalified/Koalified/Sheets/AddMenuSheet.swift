//
//  AddMenuSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

/// The "Add" menu opened by the floating + button on Today: choose to add a class, a deadline or a widget.
/// Each choice runs its callback and then closes the sheet.
struct AddMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAddClass: () -> Void
    let onAddDeadline: () -> Void
    let onAddWidget: () -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: Layout.screenPadding) {
            HStack {
                Spacer()
                TextButton(title: "Done") { dismiss() }
            }
            
            
          SecondaryButton(title: "Add a class", message: "Add to your weekly timetable") {
                onAddClass()
                dismiss()
            }
            SecondaryButton(title: "Add a deadline", message: "Assignment, quiz or exam date") {
                onAddDeadline()
                dismiss()
            }
            SecondaryButton(title: "Add a widget", message: "Show your week on the Home screen") {
                onAddWidget()
                dismiss()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
    }
    
}


#Preview {
    AddMenuSheet(onAddClass: {}, onAddDeadline: {}, onAddWidget: {})
}
