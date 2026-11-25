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
    /// Text drawn on the card; pass `CourseColor.onColor` so bright courses get dark text.
    var onCourseColor: Color = .white
    let assessmentTitle: String
    let weight: Double
    let dueDate: Date
    let hasHurdle: Bool
    let hurdlePercent: Int?
    /// Whether the stub is showing. Owned by the wallet, which opens the card once it's presented.
    let openCard: Bool
    /// Saved done state; the card starts with its stub already ripped off when true.
    var isDone: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isTorn = false
    @State private var stubFallen = false
    @State private var stubGone = false
    @State private var buttonPressed = false
    /// True while this card's own rip or undo is animating. The saved state is updated as soon as
    /// the button is tapped, and this stops that change from snapping the card to its end state.
    @State private var isAnimatingChange = false
    /// Measured height of the top of the card, so the stub's gradient can carry on from it.
    @State private var topHeight: CGFloat = 0

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
                onCourse: onCourseColor,
                assessmentTitle: assessmentTitle,
                weight: weight,
                dueDate: dueDate,
                hasHurdle: hasHurdle,
                hurdlePercent: hurdlePercent,
                openCard: openCard,
                isTorn: isTorn,
                isDone: stubGone,
                showsStub: showsStub,
                onAddMark: onView,
                onUndo: undoDone
            )
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { topHeight = $0 }
            .zIndex(1) // The stub slides out from underneath when the card opens

            if showsStub {
                AssessmentCardStub(
                    courseColor: courseColor,
                    onCourse: onCourseColor,
                    isTorn: isTorn,
                    topHeight: topHeight,
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
        // Soft glow in the course colour under the card.
        .shadow(color: courseColor.opacity(0.35), radius: 12, y: 6)
        .sensoryFeedback(.impact(weight: .light), trigger: buttonPressed)
        .onAppear(perform: syncWithSavedState)
        .onChange(of: isDone) {
            guard !isAnimatingChange else { return }
            syncWithSavedState()
        }
    }

    /// Matches the rip state to the saved done state, without replaying the animation. Runs when
    /// the card is shown fresh or the saved state changes somewhere else.
    private func syncWithSavedState() {
        isTorn = isDone
        stubFallen = isDone
        stubGone = isDone
    }

    /// Tears the stub off along the dashed line and lets it fall away. The top of the card stays
    /// with a torn edge, so it can still be opened and closed.
    private func markAsDone() {
        guard !isTorn else { return }
        buttonPressed.toggle()
        // Save first: if the card is dismissed before the animation ends, the change still sticks.
        isAnimatingChange = true
        onDone()
        withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.12)) {
            isTorn = true
        } completion: {
            withAnimation(.easeIn(duration: reduceMotion ? 0.2 : 0.4)) {
                stubFallen = true
            } completion: {
                withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.85)) {
                    stubGone = true
                }
                isAnimatingChange = false
            }
        }
    }

    /// Reattaches the stub: it slides back out from under the top of the card, then the torn edge
    /// straightens back into the dashed line.
    private func undoDone() {
        guard stubGone else { return }
        buttonPressed.toggle()
        // Save first: if the card is dismissed before the animation ends, the change still sticks.
        isAnimatingChange = true
        onUndo()
        withAnimation(reduceMotion ? .easeIn(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.85)) {
            stubGone = false
            stubFallen = false
        } completion: {
            withAnimation(.easeOut(duration: reduceMotion ? 0 : 0.15)) {
                isTorn = false
            }
            isAnimatingChange = false
        }
    }
}


#Preview {
    AssessmentCard(courseCode: "CSSE3200", courseColor: CourseColor.teal.color, assessmentTitle: "Quiz 1", weight: 10, dueDate: .now.addingTimeInterval(3 * 86_400), hasHurdle: true, hurdlePercent: 20, openCard: true)
        .mainContainerStyling()
}
