//
//  AssessmentCardStub.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

/// Stub below the dashed line. It rips off when the assessment is marked as done.
struct AssessmentCardStub: View {

    let courseColor: Color
    /// Ink for the dashed tear line, matching the text on the top of the card.
    let onCourse: Color
    let isTorn: Bool
    /// Height of the top of the card; lets the stub's gradient carry on from it.
    let topHeight: CGFloat

    @State private var height: CGFloat = 1

    var onDone: () -> Void
    var onEdit: () -> Void
    var onAddMark: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // A deeper shade of the course colour so it stands out from the card.
            TicketButton(title: "Mark as Done", ink: onCourse, fill: courseColor.mix(with: .black, by: 0.25), action: onDone)

            HStack(spacing: 8) {
                TicketButton(title: "Edit", ink: onCourse, action: onEdit)
                TicketButton(title: "Add mark", ink: onCourse, action: onAddMark)
                TicketButton(title: "Delete", ink: onCourse, action: onDelete)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = max($0, 1) }
        .ticketPiece(seam: .top, tear: isTorn ? 1 : 0, fill: courseColor, continuesBelow: topHeight / height)
        .overlay(alignment: .top) {
            HLine()
                .stroke(onCourse.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .opacity(isTorn ? 0 : 1) // The jagged tear replaces the dashed line
        }
    }
}
