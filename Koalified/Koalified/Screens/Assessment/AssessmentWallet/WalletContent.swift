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
    @State private var statusFilter: StatusFilter = .any

    /// Filters the stack by whether an assessment has been marked as done.
    enum StatusFilter: CaseIterable {
        case any, toDo, done

        var label: String {
            switch self {
            case .any:  "Any status"
            case .toDo: "To do"
            case .done: "Done"
            }
        }

        func includes(_ item: AssessmentItem) -> Bool {
            switch self {
            case .any:  true
            case .toDo: !item.isDone
            case .done: item.isDone
            }
        }
    }

    /// The card lifted out of the stack, if any.
    @State private var presented: AssessmentItem?
    /// Whether the presented card's stub is out. Opens after the card arrives and closes before it leaves.
    @State private var isCardOpen = false
    /// Whether the add-assessment sheet is showing.
    @State private var isAdding = false
    /// The assessment open in the edit sheet.
    @State private var editing: AssessmentItem?
    /// The assessment shown in the add-mark pop-up.
    @State private var marking: AssessmentItem?
    /// The assessment waiting on the delete confirmation.
    @State private var deleting: AssessmentItem?

    @Namespace private var walletNamespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext

    private var currentSemesterCourses: [Course] { courses.currentSemester }

    /// Assessments for the selected course (or every current-semester course when "All" is
    /// selected) that match the status filter. Latest due first: later cards sit on top of the
    /// stack, so this puts the one due soonest at the front, fully visible.
    private var visibleAssessments: [AssessmentItem] {
        let source = course.map { [$0] } ?? currentSemesterCourses
        return source
            .flatMap(\.assessments)
            .filter(statusFilter.includes)
            .sorted { $0.dueDate > $1.dueDate }
    }

    private var moveAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.4)
    }

    private var stubAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.3)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {

                WalletHeader()
                Text("Your semester. One ticket at a time.")
                    .secondaryTextStyling()

                HStack(alignment: .top, spacing: 12) {
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

                    FloatingDropdown(
                        options: StatusFilter.allCases,
                        selection: $statusFilter
                    ) { $0.label }
                }
                .zIndex(3)

                ScrollView {
                    cardStack
                        // Room for the last card's glow, which the scroll view would otherwise cut off flat.
                        .padding(.bottom, Layout.screenPadding * 2)
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

                card(for: item, isOpen: isCardOpen)
                    // A fresh card per assessment, so rip state never carries over to the next one.
                    .id(item.id)
                    .matchedGeometryEffect(id: item.id, in: walletNamespace, properties: .position)
                    .padding(.horizontal, Layout.screenPadding)
                    .accessibilityAction(.escape, dismiss)
                    // Swap instantly with the stack copy; matchedGeometryEffect does the move.
                    .transition(.identity)
                    .zIndex(2)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: presented?.id)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAdding = true
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                }
                .accessibilityLabel("Add an assessment")
                // The dimmed backdrop doesn't cover the navigation bar, so keep it out of reach while a card is up.
                .disabled(presented != nil)
            }
        }
        .sheet(isPresented: $isAdding) {
            AddAssessmentSheet(onAdded: {})
                .sheetBorder()
        }
        .sheet(item: $editing) { item in
            AddAssessmentSheet(onAdded: {}, assessment: item)
                .sheetBorder()
        }
        .addMarkPopup(item: $marking)
        .confirmationDialog(
            "Are you sure you want to delete this?",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            titleVisibility: .visible,
            presenting: deleting
        ) { item in
            Button("Delete", role: .destructive) { delete(item) }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }

    /// Overlapping cards; later cards sit on top, so only the header strip of each earlier card shows.
    /// Every card but the last gets a slot just the height of that strip and draws past it.
    private var cardStack: some View {
        let items = visibleAssessments
        return VStack(spacing: 0) {
            ForEach(items) { item in
                stackSlot(for: item)
                    .frame(height: item.id == items.last?.id ? nil : AssessmentCardTop.headerStripHeight,
                           alignment: .top)
            }
        }
    }

    @ViewBuilder
    private func stackSlot(for item: AssessmentItem) -> some View {
        if presented?.id == item.id {
            // Holds the card's slot while it's presented.
            card(for: item, isOpen: false)
                .fixedSize(horizontal: false, vertical: true)
                .hidden()
                .transition(.identity)
        } else {
            card(for: item, isOpen: false)
                // Lay out at full height even though the slot is only a strip tall.
                .fixedSize(horizontal: false, vertical: true)
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
                // No cross-fade with the presented copy, which made cards see-through mid-move.
                .transition(.identity)
        }
    }

    /// Empty for an assessment that was just deleted, so a stale card never reads it.
    @ViewBuilder
    private func card(for item: AssessmentItem, isOpen: Bool) -> some View {
        if item.isLive {
            AssessmentCard(
                courseCode: item.course?.courseCode ?? "",
                courseColor: item.course?.color.color ?? Color.cardSurface,
                onCourseColor: item.course?.color.onColor ?? Color.textPrimary,
                assessmentTitle: item.title,
                weight: item.weight,
                dueDate: item.dueDate,
                hasHurdle: item.hurdle ?? false,
                hurdlePercent: item.hurdlePercent,
                openCard: isOpen,
                isDone: item.isDone,
                isMarked: item.mark != nil,
                onEdit: { editing = item },
                onView: { marking = item },
                onDelete: { deleting = item },
                onDone: { setDone(true, for: item) },
                onUndo: { setDone(false, for: item) }
            )
        }
    }

    /// Saves straight away: autosave alone sometimes lost the change when the app was closed soon after.
    /// Also refreshes the reminders and widget, which both skip assessments that are done.
    private func setDone(_ isDone: Bool, for item: AssessmentItem) {
        item.isDone = isDone
        AppSync.dataChanged(in: modelContext)
    }

    /// Puts the card back out of view, then deletes the assessment.
    private func delete(_ item: AssessmentItem) {
        if presented?.id == item.id {
            isCardOpen = false
            withAnimation(moveAnimation) { presented = nil }
        }
        modelContext.delete(item)
        AppSync.dataChanged(in: modelContext)
    }

    /// Lifts the card out of the stack, then slides its stub out.
    private func present(_ item: AssessmentItem) {
        guard presented == nil else { return }
        withAnimation(moveAnimation, completionCriteria: .logicallyComplete) {
            presented = item
        } completion: {
            // Skip if the card was dismissed before it finished arriving.
            guard presented?.id == item.id else { return }
            withAnimation(stubAnimation) {
                isCardOpen = true
            }
        }
    }

    /// Tucks the stub away, then puts the card back in its slot. If the stub isn't out yet
    /// (tapped away mid-arrival) the card goes straight back.
    private func dismiss() {
        guard presented != nil else { return }
        guard isCardOpen else {
            withAnimation(moveAnimation) { presented = nil }
            return
        }
        withAnimation(stubAnimation, completionCriteria: .logicallyComplete) {
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
