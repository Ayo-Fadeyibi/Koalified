//
//  AssessmentCardStub.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

/// Stub below the dashed line. It rips off when the assessment is marked as done.
struct AssessmentCardStub: View {

    let isTorn: Bool

    var onDone: () -> Void
    var onEdit: () -> Void
    var onAddMark: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlainPrimaryButton(title: "Mark as Done", action: onDone)

            HStack(spacing: 8) {
                ActionButton(title: "Edit", color: Color.tintMint, action: onEdit)
                ActionButton(title: "Add mark", action: onAddMark)
                ActionButton(title: "Delete", color: Color.errorText, action: onDelete)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, Layout.screenPadding)
        .padding(.bottom, Layout.screenPadding + 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ticketPiece(seam: .top, tear: isTorn ? 1 : 0)
        .overlay(alignment: .top) {
            HLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .padding(.horizontal, Layout.screenPadding)
                .opacity(isTorn ? 0 : 1) // The jagged tear replaces the dashed line
        }
    }
}
