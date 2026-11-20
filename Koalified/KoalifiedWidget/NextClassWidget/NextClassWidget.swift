import WidgetKit
import SwiftUI

/// Cream fill with a 2pt black border drawn cleanly inside the widget's corner radius.
private struct WidgetBackground: View {
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.widgetCream)
            ContainerRelativeShape().strokeBorder(Color.inkBorder, lineWidth: 2)
        }
    }
}

/// Reusable Neo-Brutalist pill badge matching the main app.
private struct WidgetPill<Content: View>: View {
    let fill: Color
    var hasShadow: Bool = false
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(fill)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))
            .background {
                if hasShadow {
                    Capsule()
                        .fill(Color.inkBorder)
                        .offset(x: 2, y: 2)
                }
            }
    }
}

struct NextClassWidgetView: View {
    let entry: NextClassEntry

    var body: some View {
        if let next = entry.next {
            let isLive = next.start <= entry.date

            VStack(alignment: .leading, spacing: 0) {
                // 1. Top Row: Status Pill + Course Code Pill
                HStack(spacing: 8) {
                    WidgetPill(fill: isLive ? Color.widgetAmber : Color.widgetMint) {
                        statusHeader(for: next, isLive: isLive)
                            .font(fredoka(11, .bold))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.textPrimary)
                    }

                    Spacer(minLength: 4)

                    WidgetPill(fill: Color.widgetCream) {
                        Text(verbatim: next.courseCode)
                            .font(fredoka(12, .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                }

                Spacer(minLength: 8)

                // 2. Center Hero Row: Framed Room Code + Building & Time
                HStack(alignment: .center, spacing: 12) {
                    Text(verbatim: next.room ?? "TBA")
                        .font(fredoka(26, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isLive ? Color.widgetAmber : Color.widgetCream)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.inkBorder, lineWidth: 2)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.inkBorder)
                                .offset(x: 3, y: 3)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        if let building = next.building {
                            Text(verbatim: building)
                                .font(fredoka(15, .bold))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(1)
                        }

                        Text(verbatim: timeAndTypeLine(for: next))
                            .font(fredoka(13, .medium))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                // 3. Bottom Action Footer
                HStack {
                    Text("Open class details")
                        .font(fredoka(13, .semibold))
                        .foregroundStyle(Color.greenDeep)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .padding(5)
                        .background(Color.widgetAmber)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.inkBorder, lineWidth: 1.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            emptyStateView
        }
    }

    // MARK: - Empty State ("All done today")
    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetPill(fill: Color.widgetMint) {
                Text("A LITTLE BREATHING ROOM")
                    .font(fredoka(11, .bold))
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer(minLength: 8)

            Text("All done for today.")
                .font(fredoka(24, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Classes wrapped. Get some rest.")
                .font(fredoka(14, .regular))
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 2)

            Spacer(minLength: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Helpers
    @ViewBuilder
    private func statusHeader(for next: ClassSnapshot, isLive: Bool) -> some View {
        if isLive {
            Text("IN PROGRESS · NOW")
        } else {
            Text("NEXT · \(next.start, style: .relative)")
        }
    }

    /// "Lecture · 9:00 am – 10:00 am"
    private func timeAndTypeLine(for next: ClassSnapshot) -> String {
        let start = next.start.formatted(date: .omitted, time: .shortened)
        let end = next.end.formatted(date: .omitted, time: .shortened)
        return "\(next.typeLabel) · \(start) – \(end)"
    }
}

struct NextClassWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextClassWidget", provider: NextClassProvider()) { entry in
            NextClassWidgetView(entry: entry)
                .containerBackground(for: .widget) { WidgetBackground() }
        }
        .configurationDisplayName("Next class")
        .description("Your next class, where it is and when it starts.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    NextClassWidget()
} timeline: {
    // 1. Upcoming class state (Mint pill + Cream room tile)
    NextClassEntry(date: .now, next: ClassSnapshot(
        courseCode: "CSSE1001",
        typeLabel: "Lecture",
        start: .now.addingTimeInterval(20 * 60),
        end: .now.addingTimeInterval(80 * 60),
        room: "50-201",
        building: "Hawken Engineering"
    ))

    // 2. Live "NOW" state (Amber pill + Amber room tile)
    NextClassEntry(date: .now, next: ClassSnapshot(
        courseCode: "COMP2140",
        typeLabel: "Workshop",
        start: .now.addingTimeInterval(-10 * 60),
        end: .now.addingTimeInterval(50 * 60),
        room: "11A-130",
        building: "ModWest"
    ))

    // 3. Empty state ("All done for today.")
    NextClassEntry(date: .now, next: nil)
}
