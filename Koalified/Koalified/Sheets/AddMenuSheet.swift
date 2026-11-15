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
            
            
            optionRow(title: "Add a class", subtitle: "Add to your weekly timetable") {
                onAddClass()
                dismiss()
            }
            optionRow(title: "Add a deadline", subtitle: "Assignment, quiz or exam date") {
                onAddDeadline()
                dismiss()
            }
            optionRow(title: "Add a widget", subtitle: "Show your week on the Home screen") {
                onAddWidget()
                dismiss()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
    }
    
    /// One tappable menu row with a title, a smaller subtitle and an arrow.
    private func optionRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .secondaryTextStyling()
                }
                
                Spacer()
                
                Text(">")
                    .font(.fredoka(.body))
                    .foregroundStyle(Color.textPrimary)
            }.boxStyling(bgColor: Color.cardSurface, cRadius: Layout.radiusLarge, sColor: Color.textPrimary, lWidth: 2)
            
        }
        
        
    }
    
    
}


#Preview {
    AddMenuSheet(onAddClass: {}, onAddDeadline: {}, onAddWidget: {})
}
