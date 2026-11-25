//
//  AddMarkPopup.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/11/2026.
//

import SwiftUI
import SwiftData

/// A centred pop-up card over a dimmed backdrop that lets the user enter the percentage mark
/// for one assessment. Shown while `item` is non-nil; saving writes the mark and clears `item`.
private struct AddMarkPopup: ViewModifier {

    @Binding var item: AssessmentItem?
    let onSaved: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay {
                if let item {
                    ZStack {
                        // Dimmed backdrop; tapping it cancels.
                        Color.black.opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture { close() }

                        AddMarkCard(item: item, onCancel: close, onSaved: saved)
                        .frame(maxWidth: 340) // Prevents full-screen stretch on wider iPhones
                        .padding(.horizontal, 24)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.72), value: item != nil)
    }

    private func close() {
        withAnimation(.snappy(duration: 0.2)) { item = nil }
    }

    private func saved() {
        close()
        onSaved()
    }
}

/// The card inside the pop-up: assessment details, a mark field and Save/Cancel buttons.
private struct AddMarkCard: View {
    let item: AssessmentItem
    let onCancel: () -> Void
    let onSaved: () -> Void

    @Environment(\.modelContext) private var context
    @FocusState private var isScoreFocused: Bool

    /// The raw score the user got, e.g. 17 in "17 out of 20".
    @State private var score: Double?
    /// What the assessment was marked out of, e.g. 20 in "17 out of 20".
    @State private var outOf: Double?
    @State private var errorMessage: LocalizedStringKey?

    /// The score as a percentage, or nil until both fields hold a usable value.
    private var percentage: Double? {
        guard let score, let outOf, outOf > 0, score >= 0 else { return nil }
        return score / outOf * 100
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {

                    Text(item.title)
                        .font(.fredoka(.title2, .semibold))
                        .foregroundStyle(Color.textPrimary)

                    Text("Worth \(item.weight.formatted(.number.precision(.fractionLength(0...1))))% of your grade")
                        .secondaryTextStyling()
                }

                HStack(alignment: .bottom, spacing: 12) {
                    FormField("Your score") {
                        TextField("e.g. 17", value: $score, format: .number)
                            .keyboardType(.decimalPad)
                            .focused($isScoreFocused)
                            .foregroundStyle(Color.textPrimary)
                    }

                    FormField("Out of") {
                        TextField("e.g. 20", value: $outOf, format: .number)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(Color.textPrimary)
                    }
                }

                // Live conversion so the user sees the percentage that will be saved.
                if let percentage {
                    Text("That's \(percentage.formatted(.number.precision(.fractionLength(0...1))))%")
                        .font(.fredoka(.headline, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: percentage)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.fredoka(.footnote, .semibold))
                        .foregroundStyle(Color.redFill)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PrimaryButton(title: "Save mark", action: save)

                TextButton(title: "Cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .onAppear(perform: loadMark)
        .sensoryFeedback(.error, trigger: showsError) { _, newValue in newValue }
    }

    private var showsError: Bool { errorMessage != nil }

    /// Prefills the score the user last entered and opens the keyboard. Marks saved before the raw
    /// score was stored only have a percentage, so those are shown out of 100.
    private func loadMark() {
        if let markScore = item.markScore, let markOutOf = item.markOutOf {
            score = markScore
            outOf = markOutOf
        } else if let mark = item.mark {
            score = mark
            outOf = 100
        }
        isScoreFocused = true
    }

    private func save() {
        guard let outOf, outOf > 0 else {
            errorMessage = "Enter what the assessment was marked out of."
            return
        }

        guard let score, score >= 0, score <= outOf else {
            errorMessage = "Your score must be between 0 and what it was out of."
            return
        }

        // Marks are stored as a percentage everywhere else in the app.
        item.mark = score / outOf * 100
        item.markScore = score
        item.markOutOf = outOf
        AppSync.dataChanged(in: context)
        onSaved()
    }
}

extension View {

    /// Presents the add-mark pop-up for `item` while it is non-nil. `onSaved` runs after the mark is saved.
    func addMarkPopup(item: Binding<AssessmentItem?>, onSaved: @escaping () -> Void = {}) -> some View {
        self.modifier(AddMarkPopup(item: item, onSaved: onSaved))
    }
}

#Preview {
    @Previewable @State var item: AssessmentItem? = AssessmentItem(title: "Assignment 1", weight: 25, dueDate: .now)

    Button("Add mark") { item = AssessmentItem(title: "Assignment 1", weight: 25, dueDate: .now) }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.screenBackground)
        .addMarkPopup(item: $item)
        .modelContainer(EmptyPreviewData.container)
}
