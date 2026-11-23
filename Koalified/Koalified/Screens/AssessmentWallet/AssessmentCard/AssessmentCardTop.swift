//
//  AssessmentCardTop.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

/// Top of the ticket. It stays after Mark as Done, so it holds the info and the done actions.
struct AssessmentCardTop: View {

    let courseCode: String
    let courseColor: Color
    let assessmentTitle: String
    let weight: Double
    let dueDate: String
    let hasHurdle: Bool
    let hurdlePercent: Int?

    @Binding var openCard: Bool
    let isTorn: Bool
    /// The stub has been ripped off.
    let isDone: Bool
    /// The stub is attached below this piece.
    let showsStub: Bool

    var onAddMark: () -> Void
    var onUndo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // --- HEADER ROW ---
            HStack(alignment: .center) { // Explicitly center
                PlainPill(title: LocalizedStringKey(courseCode), bgColor: courseColor)

                Spacer()

                expandButton
            }

            // --- DETAILS ROW ---
            HStack(alignment: .bottom) { // Align items to bottom baseline
                Text("\(assessmentTitle) · \(weight, format: .number.precision(.fractionLength(0)))%")
                    .font(.fredoka(.title2, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Spacer()

                Text(dueDate)
                    .font(.fredoka(.body, .medium)) // Slightly smaller than title2 for hierarchy
                    .foregroundStyle(Color.redFill)
            }

            // --- EXPANDABLE INFO ---
            if openCard {
                HStack {
                    Text("Due: Fri 23 Oct, 5:00 pm")
                        .boldSecondaryTextStyling()

                    Spacer()

                    if hasHurdle {
                        Text("Hurdle: \(hurdlePercent ?? 0)%")
                            .font(.fredoka(.body, .bold))
                            .foregroundStyle(courseColor)
                    }
                }
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // --- DONE ACTIONS (once the stub is gone) ---
            if openCard && isDone {
                HStack(spacing: 8) {
                    ActionButton(title: "Add mark", color: Color.tintMint, action: onAddMark)
                    ActionButton(title: "Undo", action: onUndo)
                }
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.bottom, 20)
        .padding([.horizontal, .top], Layout.screenPadding)
        .padding(.bottom, showsStub ? 0 : Layout.screenPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ticketPiece(seam: isTorn || showsStub ? .bottom : .none, tear: isTorn ? 1 : 0)
    }

    private var expandButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                openCard.toggle()
            }
        } label: {
            Image(systemName:openCard ? "minus" : "plus")
                .foregroundStyle(Color.textPrimary)
                .fontWeight(.bold)
                .padding(10)
                .frame(width: 35, height: 35)
                .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: 5)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: openCard)
    }
}
