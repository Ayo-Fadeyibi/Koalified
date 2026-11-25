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

                        AddMarkCard(item: item, onCancel: close, onSaved: {
                            close()
                            onSaved()
                        })
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
}

/// The card inside the pop-up: assessment details, a mark field and Save/Cancel buttons.
private struct AddMarkCard: View {
    let item: AssessmentItem
    let onCancel: () -> Void
    let onSaved: () -> Void

    @Environment(\.modelContext) private var context
    @FocusState private var isMarkFocused: Bool

    @State private var mark: Double?
    @State private var errorMessage: LocalizedStringKey?

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add mark")
                        .font(.fredoka(.title2, .bold))
                        .foregroundStyle(Color.textPrimary)

                    Text(item.title)
                        .font(.fredoka(.subheadline, .semibold))
                        .foregroundStyle(Color.textPrimary)

                    Text("Worth \(item.weight.formatted(.number.precision(.fractionLength(0...1))))% of your grade")
                        .secondaryTextStyling()
                }

                FormField("Mark (%)") {
                    TextField("e.g. 85", value: $mark, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($isMarkFocused)
                        .foregroundStyle(Color.textPrimary)
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
        .onAppear {
            mark = item.mark
            isMarkFocused = true
        }
        .sensoryFeedback(.error, trigger: errorMessage != nil) { _, newValue in newValue }
    }

    private func save() {
        guard let mark, mark >= 0, mark <= 100 else {
            errorMessage = "Mark must be between 0 and 100."
            return
        }

        item.mark = mark
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
