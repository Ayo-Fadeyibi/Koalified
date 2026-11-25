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
    /// Text drawn straight on the card: white on deep course colours, dark on yellow and orange.
    let onCourse: Color
    let assessmentTitle: String
    let weight: Double
    let dueDate: Date
    let hasHurdle: Bool
    let hurdlePercent: Int?

    let openCard: Bool
    let isTorn: Bool
    /// The stub has been ripped off.
    let isDone: Bool
    /// The stub is attached below this piece.
    let showsStub: Bool

    var onAddMark: () -> Void
    var onUndo: () -> Void
    /// A smaller ticket for lists outside the wallet (e.g. Today): tighter padding, smaller icon and countdown.
    var compact = false

    /// Height of the strip each card shows when tucked in the wallet stack: top padding, the header
    /// row and a little breathing room below it.
    static let headerStripHeight: CGFloat = padding + iconSize + 16

    private static let padding: CGFloat = 20
    private static let iconSize: CGFloat = 48

    private var padding: CGFloat { compact ? 14 : Self.padding }
    private var iconSize: CGFloat { compact ? 36 : Self.iconSize }

    /// Whole days until the due date; negative once it's overdue.
    private var days: Int { daysUntil(dueDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 20) {
            header

            HStack(alignment: .bottom) {
                countdown
                    .layoutPriority(1) // Keep the big number full size next to the details
                Spacer(minLength: 12)
                dueDetails
            }

            weightBar

            // --- DONE ACTIONS (once the stub is gone) ---
            if openCard && isDone {
                HStack(spacing: 8) {
                    TicketButton(title: "Add mark", ink: onCourse, action: onAddMark)
                    TicketButton(title: "Undo", ink: onCourse, action: onUndo)
                }
                .transition(.opacity) // Fade in place so it never slides over the content above
            }
        }
        .foregroundStyle(onCourse)
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ticketPiece(seam: isTorn || showsStub ? .bottom : .none, tear: isTorn ? 1 : 0, fill: courseColor)
    }

    // --- HEADER: icon, title over course code, status badge ---
    // Everything that identifies the card sits here so it still shows when the card is tucked in the stack.
    private var header: some View {
        HStack(spacing: compact ? 10 : 14) {
            Image(systemName: "doc.text.fill")
                .font((compact ? Font.body : .title3).weight(.semibold))
                .frame(width: iconSize, height: iconSize)
                .background(onCourse.opacity(0.18), in: RoundedRectangle(cornerRadius: compact ? 10 : 14))
                .overlay(RoundedRectangle(cornerRadius: compact ? 10 : 14).strokeBorder(onCourse.opacity(0.3), lineWidth: 1))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(assessmentTitle)
                    .font(.fredoka(compact ? .headline : .title3, .bold))
                    .lineLimit(1)
                Text(courseCode.uppercased())
                    .font(.fredoka(.footnote, .semibold))
                    .tracking(2)
                    .opacity(0.75)
            }

            Spacer(minLength: 8)

            Text(isDone ? "Done" : "To do")
                .font(.fredoka(compact ? .caption : .subheadline, .bold))
                .padding(.horizontal, compact ? 10 : 14)
                .padding(.vertical, compact ? 5 : 7)
                .background(onCourse.opacity(0.2), in: Capsule())
                .overlay(Capsule().strokeBorder(onCourse.opacity(0.3), lineWidth: 1))
                .fixedSize()
        }
    }

    // --- BIG COUNTDOWN ---
    private var countdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(days < 0 ? "OVERDUE BY" : days == 0 ? "DUE" : "DUE IN")
                .font(.fredoka(.caption, .semibold))
                .tracking(2)
                .opacity(0.75)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if days == 0 {
                    Text("Today")
                        .font(bigNumberFont)
                } else {
                    Text(abs(days), format: .number)
                        .font(bigNumberFont)
                    Text(abs(days) == 1 ? "day" : "days")
                        .font(.fredoka(compact ? .headline : .title2, .semibold))
                        .opacity(0.85)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
    }

    private static let bigNumberFont = Font.custom(FredokaWeight.semibold.fontName, size: 56, relativeTo: .largeTitle)
    private static let compactNumberFont = Font.custom(FredokaWeight.semibold.fontName, size: 34, relativeTo: .largeTitle)
    private var bigNumberFont: Font { compact ? Self.compactNumberFont : Self.bigNumberFont }

    // --- DUE DATE AND HURDLE (right-aligned) ---
    private var dueDetails: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(dueDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
            Text(dueDate.formatted(.dateTime.hour().minute()))
            if hasHurdle {
                Text("Hurdle \(hurdlePercent ?? 0)%")
                    .fontWeight(.bold)
            }
        }
        .font(.fredoka(compact ? .footnote : .subheadline, .medium))
        .multilineTextAlignment(.trailing)
        .opacity(0.9)
        .padding(.bottom, compact ? 4 : 8)
    }

    // --- WEIGHT BAR ---
    private var weightBar: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            Capsule()
                .fill(onCourse.opacity(0.25))
                .frame(height: compact ? 4 : 6)
                .overlay(alignment: .leading) {
                    GeometryReader { proxy in
                        Capsule()
                            .fill(onCourse)
                            .frame(width: proxy.size.width * min(max(weight / 100, 0), 1))
                    }
                }
                .accessibilityHidden(true)

            Text("\(weight, format: .number.precision(.fractionLength(0...1)))% of final grade")
                .font(.fredoka(.footnote, .medium))
                .opacity(0.8)
        }
    }
}
