//
//  TodayScheduleWidget.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

//
//  TodayScheduleWidget.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Outer Container
private struct ScheduleWidgetBackground: View {
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.widgetCream)
            ContainerRelativeShape().strokeBorder(Color.inkBorder, lineWidth: 2.5)
        }
    }
}

// MARK: - Main Widget View
struct TodayScheduleWidgetView: View {
    let entry: TodayScheduleEntry

    var body: some View {
        let visible = visibleRows(from: entry.classes, at: entry.date)

        VStack(alignment: .leading, spacing: 9) {
            header

            if entry.classes.isEmpty {
                emptyState
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(visible.rows.enumerated()), id: \.offset) { _, session in
                        row(session, status: rowState(of: session, in: entry.classes, at: entry.date))
                    }
                }

                Spacer(minLength: 2)

                if visible.hiddenUpcoming > 0 {
                    overflowFooter(hiddenCount: visible.hiddenUpcoming, nextHidden: visible.firstHiddenSession)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Header ("TODAY'S SCHEDULE" + "WED 18 NOV")
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("TODAY'S SCHEDULE")
                .font(fredoka(13, .bold))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(entry.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)).uppercased())
                .font(fredoka(12, .bold))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Class Row Card
    @ViewBuilder
    private func row(_ session: ClassSnapshot, status: RowState) -> some View {
        let isDone = status == .done
        let startText = session.start.formatted(date: .omitted, time: .shortened)
        let endText = session.end.formatted(date: .omitted, time: .shortened)
        let statusWord: String = {
            switch status {
            case .done:  return "done"
            case .now:   return "now"
            case .next:  return "next"
            case .later: return "later"
            }
        }()
        let bgColor: Color = {
            switch status {
            case .done:     return Color.widgetCream
            case .now:      return Color.widgetMintRow
            case .next:     return Color.widgetAmber
            case .later: return Color.widgetRowWhite
            }
        }()

        HStack(spacing: 12) {
            // Left Column: Start & End Times
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: session.start.formatted(date: .omitted, time: .shortened).uppercased())
                    .font(fredoka(12, .bold))
                    .foregroundStyle(isDone ? Color.widgetDoneText : Color.textSecondary)

                Text(verbatim: session.end.formatted(date: .omitted, time: .shortened).uppercased())
                    .font(fredoka(11, .medium))
                    .foregroundStyle(isDone ? Color.widgetDoneText : Color.textSecondary)
            }
            .frame(width: 62, alignment: .leading)

            // Center Column: Course Code + Type · Building Room
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: session.courseCode)
                    .font(fredoka(15, .bold))
                    .foregroundStyle(isDone ? Color.widgetDoneText : Color.textPrimary)
                    .lineLimit(1)

                Text(verbatim: subtitleLine(for: session))
                    .font(fredoka(12, .medium))
                    .foregroundStyle(isDone ? Color.widgetDoneText : Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            // Right Column: Status Badge
            statusBadge(for: status)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(isDone ? Color.widgetDoneBorder : Color.inkBorder, lineWidth: isDone ? 1.5 : 2)
        )
        .background {
            if !isDone {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.inkBorder)
                    .offset(x: 2.5, y: 2.5)
            }
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel("\(session.courseCode) \(session.typeLabel), \(startText) to \(endText), \(statusWord)")
    }

    // MARK: - Right-Side Status Pill
    @ViewBuilder
    private func statusBadge(for status: RowState) -> some View {
        switch status {
        case .done:
            HStack(spacing: 3) {
                Text("DONE")
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .font(fredoka(11, .bold))
            .foregroundStyle(Color.widgetDoneText)

        case .now:
            Text("NOW")
                .font(fredoka(11, .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.widgetMint)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))

        case .next:
            Text("NEXT")
                .font(fredoka(11, .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.widgetRowWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))

        case .later:
            EmptyView()
        }
    }

    // MARK: - Subtitle ("Lecture · Hawken 50-N202")
    private func subtitleLine(for session: ClassSnapshot) -> String {
        let shortBuilding = session.building?
            .replacingOccurrences(of: " Building", with: "")
            .trimmingCharacters(in: .whitespaces)
        let location = [shortBuilding, session.room]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return [session.typeLabel, location]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    // MARK: - Bottom Overflow Footer ("+1 more · DECO1800 Lecture at 9:15 PM")
    @ViewBuilder
    private func overflowFooter(hiddenCount: Int, nextHidden: ClassSnapshot?) -> some View {
        if let nextHidden {
            let time = nextHidden.start.formatted(date: .omitted, time: .shortened).uppercased()
            Text(verbatim: "+\(hiddenCount) more · \(nextHidden.courseCode) \(nextHidden.typeLabel) at \(time)")
                .font(fredoka(12, .bold))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        } else {
            Text(verbatim: "+\(hiddenCount) more")
                .font(fredoka(12, .bold))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Spacer()
            Text("No classes today")
                .font(fredoka(22, .bold))
                .foregroundStyle(Color.textPrimary)
            Text("Your schedule is completely clear.")
                .font(fredoka(14, .regular))
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Widget Configuration
struct TodayScheduleWidget: Widget {
    let kind = "TodayScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayScheduleProvider()) { entry in
            TodayScheduleWidgetView(entry: entry)
                .containerBackground(for: .widget) { ScheduleWidgetBackground() }
        }
        .configurationDisplayName("Today's schedule")
        .description("Your classes for today, with what's on now and what's next.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Preview
private func previewClass(_ code: String, _ type: String, startsIn start: Double, minutes: Double,
                          room: String, building: String) -> ClassSnapshot {
    ClassSnapshot(
        courseCode: code,
        typeLabel: type,
        start: .now.addingTimeInterval(start * 60),
        end: .now.addingTimeInterval((start + minutes) * 60),
        room: room,
        building: building
    )
}

#Preview(as: .systemLarge) {
    TodayScheduleWidget()
} timeline: {
    // Done + now + next + upcoming
    TodayScheduleEntry(date: .now, classes: [
        previewClass("MATH1051", "Lecture", startsIn: -180, minutes: 60, room: "N202", building: "Hawken Engineering"),
        previewClass("COMP3400", "Tutorial", startsIn: -30, minutes: 90, room: "18-026", building: "Advanced Engineering Building"),
        previewClass("COMP3506", "Lecture", startsIn: 90, minutes: 60, room: "72-322", building: "Andrew Liveris Building"),
        previewClass("DECO1800", "Lecture", startsIn: 180, minutes: 60, room: "49-201", building: "Hawken Engineering")
    ])

    // Overflow footer (more classes than fit)
    TodayScheduleEntry(date: .now, classes: [
        previewClass("MATH1051", "Lecture", startsIn: -240, minutes: 60, room: "N202", building: "Hawken Engineering"),
        previewClass("COMP3400", "Tutorial", startsIn: -30, minutes: 60, room: "18-026", building: "Advanced Engineering Building"),
        previewClass("COMP3506", "Lecture", startsIn: 60, minutes: 60, room: "72-322", building: "Andrew Liveris Building"),
        previewClass("DECO1800", "Lecture", startsIn: 150, minutes: 60, room: "49-201", building: "Hawken Engineering"),
        previewClass("CSSE2310", "Practical", startsIn: 240, minutes: 60, room: "78-210", building: "Learning Innovation Building"),
        previewClass("STAT2003", "Lecture", startsIn: 330, minutes: 60, room: "N101", building: "Hawken Engineering"),
        previewClass("INFS3202", "Tutorial", startsIn: 420, minutes: 60, room: "50-S101", building: "Hawken Engineering")
    ])

    // Empty state
    TodayScheduleEntry(date: .now, classes: [])
}
