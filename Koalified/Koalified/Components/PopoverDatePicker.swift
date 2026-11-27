//
//  PopoverDatePicker.swift
//  Koalified
//

import SwiftUI

/// A styled pill showing the chosen date or time, which opens the system picker in a popover.
/// Dates use the calendar picker and close once a day is picked; times use the wheel and stay
/// open while scrolling (tap outside to close).
struct PopoverDatePicker: View {
    /// Shown on the left of the pill; `nil` for a pill with just the value.
    var title: LocalizedStringKey? = nil
    @Binding var selection: Date
    var displayedComponents: DatePickerComponents = .date

    @State private var isPresented = false

    private var showsTimeOnly: Bool { !displayedComponents.contains(.date) }

    private var formattedSelection: String {
        if showsTimeOnly {
            selection.formatted(date: .omitted, time: .shortened)
        } else if displayedComponents.contains(.hourAndMinute) {
            selection.formatted(date: .abbreviated, time: .shortened)
        } else {
            selection.formatted(date: .abbreviated, time: .omitted)
        }
    }

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 5) {
                if let title {
                    Text(title)
                    Spacer(minLength: 8)
                }

                Text(formattedSelection)

                // One chevron that flips, like `FloatingDropdown`. The animation is attached here
                // rather than to the tap so it also plays when the popover closes on its own
                // (tapping outside or picking a day).
                Image(systemName: "chevron.down")
                    .fontWeight(.bold)
                    .rotationEffect(.degrees(isPresented ? 180 : 0))
                    .animation(.snappy(duration: 0.25), value: isPresented)
            }
            .font(.fredoka(.body, .bold))
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
            .plainStyling()
        }
        .buttonStyle(.plain)
        // The button owns the popover, so the chevron always matches whether it's open
        // (tapping outside dismisses it and resets `isPresented`).
        .popover(isPresented: $isPresented) {
            picker
                .labelsHidden()
                .padding()
                // Popovers size to the content's *ideal* size, so this needs a fixed
                // width; `maxWidth: .infinity` has no ideal and is ignored.
                .frame(width: showsTimeOnly ? 280 : 340)
                .presentationCompactAdaptation(.popover)
        }
        // Close once a day is picked, like the system compact picker. The time wheel changes
        // the value continuously while scrolling, so it stays open.
        .onChange(of: selection) {
            if !showsTimeOnly { isPresented = false }
        }
    }

    @ViewBuilder
    private var picker: some View {
        if showsTimeOnly {
            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .datePickerStyle(.wheel)
        } else {
            DatePicker("", selection: $selection, displayedComponents: displayedComponents)
                .datePickerStyle(.graphical)
        }
    }
}

#Preview {
    @Previewable @State var date = Date.now

    VStack(spacing: 20) {
        PopoverDatePicker(selection: $date)
        PopoverDatePicker(title: "Date", selection: $date)
        PopoverDatePicker(title: "Starts", selection: $date, displayedComponents: .hourAndMinute)
    }
    .padding()
    .background(Color.screenBackground)
}
