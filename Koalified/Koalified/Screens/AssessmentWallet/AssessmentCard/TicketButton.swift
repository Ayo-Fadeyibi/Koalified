//
//  TicketButton.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/11/2026.
//

import SwiftUI

/// Rounded button for the assessment ticket. Translucent by default so the card's gradient shows
/// through; pass a `fill` for a solid button such as Mark as Done.
struct TicketButton: View {
    let title: LocalizedStringKey
    /// Text and outline colour; the card's `onCourse` colour.
    let ink: Color
    var fill: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.fredoka(fill == nil ? .subheadline : .body, .bold))
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, fill == nil ? 10 : 14)
                .background(fill ?? ink.opacity(0.18), in: Capsule())
                .overlay(Capsule().strokeBorder(ink.opacity(0.3), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        TicketButton(title: "Mark as Done", ink: .white, fill: CourseColor.teal.color.mix(with: .black, by: 0.2)) {}
        HStack {
            TicketButton(title: "Edit", ink: .white) {}
            TicketButton(title: "Delete", ink: .white) {}
        }
    }
    .padding()
    .background(CourseColor.teal.color)
}
