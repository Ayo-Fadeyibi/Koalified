import WidgetKit
import SwiftUI

private extension Color {
    static let widgetCream   = Color(red: 1.000, green: 0.992, blue: 0.973) // #FFFDF8
    static let widgetAmber   = Color(red: 1.000, green: 0.890, blue: 0.651) // #FFE3A6
    static let widgetMint    = Color(red: 0.322, green: 0.839, blue: 0.612) // #52D69C
    static let widgetInk     = Color.black
    static let widgetText    = Color(red: 0.090, green: 0.173, blue: 0.153) // #172C27
    static let widgetMuted   = Color(red: 0.271, green: 0.369, blue: 0.325) // #455E53
    static let widgetAction  = Color(red: 0.118, green: 0.337, blue: 0.263) // #1E5643
}

private func fredoka(_ size: CGFloat, _ weight: Font.Weight) -> Font {
    // Fredoka ships as one file per weight, so pick the PostScript name rather than the family.
    let name: String
    switch weight {
    case .bold, .heavy, .black: name = "Fredoka-Bold"
    case .semibold:             name = "Fredoka-SemiBold"
    case .medium:               name = "Fredoka-Medium"
    default:                    name = "Fredoka-Regular"
    }
    return .custom(name, fixedSize: size)
}

/// Cream fill with a 2pt black border drawn cleanly inside the widget's corner radius.
private struct WidgetBackground: View {
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.widgetCream)
            ContainerRelativeShape().strokeBorder(Color.widgetInk, lineWidth: 2)
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
            .overlay(Capsule().stroke(Color.widgetInk, lineWidth: 1.5))
            .background {
                if hasShadow {
                    Capsule()
                        .fill(Color.widgetInk)
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
                            .foregroundStyle(Color.widgetInk)
                    }

                    Spacer(minLength: 4)

                    WidgetPill(fill: Color.widgetCream) {
                        Text(verbatim: next.courseCode)
                            .font(fredoka(12, .bold))
                            .foregroundStyle(Color.widgetText)
                    }
                }

                Spacer(minLength: 8)

                // 2. Center Hero Row: Framed Room Code + Building & Time
                HStack(alignment: .center, spacing: 12) {
                    Text(verbatim: next.room ?? "TBA")
                        .font(fredoka(26, .bold))
                        .foregroundStyle(Color.widgetInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isLive ? Color.widgetAmber : Color.widgetCream)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.widgetInk, lineWidth: 2)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.widgetInk)
                                .offset(x: 3, y: 3)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        if let building = next.building {
                            Text(verbatim: building)
                                .font(fredoka(15, .bold))
                                .foregroundStyle(Color.widgetText)
                                .lineLimit(1)
                        }

                        Text(verbatim: timeAndTypeLine(for: next))
                            .font(fredoka(13, .medium))
                            .foregroundStyle(Color.widgetMuted)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                // 3. Bottom Action Footer
                HStack {
                    Text("Open class details")
                        .font(fredoka(13, .semibold))
                        .foregroundStyle(Color.widgetAction)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.widgetInk)
                        .padding(5)
                        .background(Color.widgetAmber)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.widgetInk, lineWidth: 1.5))
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
                    .foregroundStyle(Color.widgetInk)
            }

            Spacer(minLength: 8)

            Text("All done for today.")
                .font(fredoka(24, .bold))
                .foregroundStyle(Color.widgetText)

            Text("Classes wrapped. Get some rest.")
                .font(fredoka(14, .regular))
                .foregroundStyle(Color.widgetMuted)
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
