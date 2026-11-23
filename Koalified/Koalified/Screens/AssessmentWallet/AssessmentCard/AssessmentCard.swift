//
//  AssessmentCard.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

/// Ticket-style assessment card. Marking it as done rips off the stub below the dashed line;
/// the top of the card stays so it can still be opened, given a mark, or undone.
struct AssessmentCard: View {

    let courseCode: String
    let courseColor: Color
    let assessmentTitle: String
    let weight: Double
    let dueDate: String
    let hasHurdle: Bool
    let hurdlePercent: Int?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openCard = false
    @State private var isTorn = false
    @State private var stubFallen = false
    @State private var stubGone = false
    @State private var buttonPressed = false

    var onEdit: () -> Void = {}
    var onView: () -> Void = {}
    var onDelete: () -> Void = {}
    var onDone: () -> Void = {}
    var onUndo: () -> Void = {}

    /// The stub is only attached while the card is open and hasn't been ripped off yet.
    private var showsStub: Bool { openCard && !stubGone }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AssessmentCardTop(
                courseCode: courseCode,
                courseColor: courseColor,
                assessmentTitle: assessmentTitle,
                weight: weight,
                dueDate: dueDate,
                hasHurdle: hasHurdle,
                hurdlePercent: hurdlePercent,
                openCard: $openCard,
                isTorn: isTorn,
                isDone: stubGone,
                showsStub: showsStub,
                onAddMark: onView,
                onUndo: undoDone
            )
            .zIndex(1) // The stub slides out from underneath when the card opens

            if showsStub {
                AssessmentCardStub(
                    isTorn: isTorn,
                    onDone: markAsDone,
                    onEdit: onEdit,
                    onAddMark: onView,
                    onDelete: onDelete
                )
                .rotationEffect(.degrees(stubFallen && !reduceMotion ? 12 : 0), anchor: .topLeading)
                .offset(y: stubFallen && !reduceMotion ? 90 : 0)
                .opacity(stubFallen ? 0 : 1)
                .allowsHitTesting(!isTorn)
                .accessibilityHidden(isTorn)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sensoryFeedback(.impact(weight: .light), trigger: buttonPressed)
    }

    /// Tears the stub off along the dashed line and lets it fall away. The top of the card stays
    /// with a torn edge, so it can still be opened and closed.
    private func markAsDone() {
        guard !isTorn else { return }
        buttonPressed.toggle()
        withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.12)) {
            isTorn = true
        } completion: {
            withAnimation(.easeIn(duration: reduceMotion ? 0.2 : 0.4)) {
                stubFallen = true
            } completion: {
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                    stubGone = true
                    onDone()
                }
            }
        }
    }

    /// Reattaches the stub: it slides back out from under the top of the card, then the torn edge
    /// straightens back into the dashed line.
    private func undoDone() {
        guard stubGone else { return }
        buttonPressed.toggle()
        withAnimation(reduceMotion ? .easeIn(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.85)) {
            stubGone = false
            stubFallen = false
        } completion: {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.15)) {
                isTorn = false
            }
            onUndo()
        }
    }
}


#Preview {
    AssessmentCard(courseCode: "CSSE3200", courseColor: Color.mintFill, assessmentTitle: "Quiz 1", weight: 10, dueDate: "3 Days left", hasHurdle: true, hurdlePercent: 20)
        .mainContainerStyling()
}
