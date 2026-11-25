//
//  WalletContent.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI
import SwiftData

/// Apple Wallet-style stack of assessment tickets. Tapping a card lifts it out of the stack,
/// dims everything behind it and opens its stub so the buttons can be used.
struct WalletContent: View {

    @Query private var courses: [Course]
    @State private var course: Course?

    /// The card lifted out of the stack, if any.
    @State private var presented: AssessmentItem?
    /// Whether the presented card's stub is out. Opens after the card arrives and closes before it leaves.
    @State private var isCardOpen = false

    @Namespace private var walletNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How much each card is tucked under the next one, leaving just its header row showing.
    private let stackOverlap: CGFloat = 62

    private var currentSemesterCourses: [Course] {
        guard let newest = courses.newestFirst.first else {
            return []
        }

        return courses.filter {
            $0.year == newest.year && $0.term == newest.term
        }
    }

    /// Assessments for the selected course, or every current-semester course when "All" is selected.
    private var visibleAssessments: [AssessmentItem] {
        let source = course.map { [$0] } ?? currentSemesterCourses
        return source
            .flatMap(\.assessments)
            .sorted { $0.dueDate < $1.dueDate }
    }

    private var moveAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.82)
    }

    private var stubAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.8)
    }

    /// Closing the presented card (its − button) dismisses it back into the stack.
    private var cardOpenBinding: Binding<Bool> {
        Binding(
            get: { isCardOpen },
            set: { isOpen in
                if isOpen { isCardOpen = true } else { dismiss() }
            }
        )
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {

                WalletHeader()
                Text("Your semester. One ticket at a time.")
                    .secondaryTextStyling()

                FloatingDropdown(
                    options: [nil] + currentSemesterCourses.map { Optional($0) },
                    selection: $course
                ) { selectedCourse in
                    selectedCourse?.courseCode
                        ?? (currentSemesterCourses.isEmpty
                            ? "No current courses"
                            : "All")
                }
                .disabled(currentSemesterCourses.isEmpty)
                .zIndex(3)

                ScrollView {
                    cardStack
                        .padding(.bottom, Layout.screenPadding)
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(presented != nil)
            }
            .padding(.top, Layout.screenPadding)
            .mainContainerStyling()
            .accessibilityHidden(presented != nil)

            // --- PRESENTED CARD ---
            if let item = presented {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture(perform: dismiss)
                    .accessibilityHidden(true)
                    .transition(.opacity)
                    .zIndex(1)

                card(for: item, isOpen: cardOpenBinding)
                    .matchedGeometryEffect(id: item.id, in: walletNamespace, properties: .position)
                    .padding(.horizontal, Layout.screenPadding)
                    .accessibilityAction(.escape, dismiss)
                    .zIndex(2)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: presented?.id)
    }

    /// Overlapping cards; later cards sit on top, so only the header row of each earlier card shows.
    private var cardStack: some View {
        VStack(spacing: -stackOverlap) {
            ForEach(visibleAssessments) { item in
                if presented?.id == item.id {
                    // Holds the card's slot while it's presented.
                    card(for: item, isOpen: .constant(false))
                        .hidden()
                } else {
                    card(for: item, isOpen: .constant(false))
                        .matchedGeometryEffect(id: item.id, in: walletNamespace, properties: .position)
                        // Catch taps over the whole card so its buttons only work once presented.
                        .overlay {
                            Color.clear
                                .contentShape(.rect)
                                .onTapGesture { present(item) }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAction { present(item) }
                        // The rest of the stack drops back while a card is presented.
                        .scaleEffect(presented == nil ? 1 : 0.96)
                        .offset(y: presented == nil ? 0 : 24)
                }
            }
        }
    }

    private func card(for item: AssessmentItem, isOpen: Binding<Bool>) -> some View {
        AssessmentCard(
            courseCode: item.course?.courseCode ?? "",
            courseColor: item.course?.color.color ?? Color.cardSurface,
            assessmentTitle: item.title,
            weight: item.weight,
            dueDate: item.dueDate,
            hasHurdle: item.hurdle ?? false,
            hurdlePercent: item.hurdlePercent,
            openCard: isOpen,
            isDone: item.isDone,
            onDone: { item.isDone = true },
            onUndo: { item.isDone = false }
        )
    }

    /// Lifts the card out of the stack, then slides its stub out.
    private func present(_ item: AssessmentItem) {
        guard presented == nil else { return }
        withAnimation(moveAnimation) {
            presented = item
        } completion: {
            withAnimation(stubAnimation) {
                isCardOpen = true
            }
        }
    }

    /// Tucks the stub away, then puts the card back in its slot.
    private func dismiss() {
        guard presented != nil, isCardOpen else { return }
        withAnimation(stubAnimation) {
            isCardOpen = false
        } completion: {
            withAnimation(moveAnimation) {
                presented = nil
            }
        }
    }
}


#Preview {
    WalletContent()
        .modelContainer(PreviewData.container)
}
