//
//  AddMenuSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/10/2026.
//

import SwiftUI

struct AddMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onAddClass: () -> Void
    let onAddDeadline: () -> Void
    let onAddWidget: () -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            HStack {
                Text("Add")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundStyle(Color.inkPrimary)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundStyle(Color.accentText)
                        .fontWeight(.bold)
                }
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
            .background(Color.canvas)
    }
    
    private func optionRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.inkPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.inkSecondary)
            }
            .padding(14)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    AddMenuSheet(onAddClass: {}, onAddDeadline: {}, onAddWidget: {})
}
