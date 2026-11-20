//
//  ImportantDatesWidget.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import WidgetKit
import SwiftUI

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

struct ImportantDatesWidgetView: View {
    let entry: ImportantDatesEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        default:            mediumView
        }
    }
    
    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Eyebrow Header
            HStack {
                Text("SEMESTER MILESTONES")
                    .font(fredoka(11, .bold))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Text("UQ")
                    .font(fredoka(10, .bold))
                    .foregroundStyle(Color.inkBorder)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.widgetMint)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))
            }

            // Milestone Cards Row
            if entry.milestones.isEmpty {
                mediumEmptyView
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(entry.milestones.prefix(3).enumerated()), id: \.element.id) { index, milestone in
                        milestoneCard(milestone, isNext: index == 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // Shown when all semester milestones have passed
    private var mediumEmptyView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()

            Text("All wrapped!")
                .font(fredoka(20, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("No milestones left this semester.")
                .font(fredoka(12, .regular))
                .foregroundStyle(Color.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    // Split out of `mediumView` so the type-checker can handle each piece.
    private func milestoneCard(_ milestone: Milestone, isNext: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12)
        let fill: Color = isNext ? .widgetAmber : .widgetCream
        let label: String = daysLabel(daysUntil(milestone.date, from: entry.date))

        return VStack(alignment: .leading, spacing: 4) {
            Text(milestone.title)
                .font(fredoka(11, .bold))
                .textCase(.uppercase)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 2)

            Text(label)
                .font(fredoka(20, .bold))
                .foregroundStyle(Color.inkBorder)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(milestone.date, format: .dateTime.day().month(.abbreviated))
                .font(fredoka(11, .semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(fill)
        .clipShape(shape)
        .overlay(shape.stroke(Color.inkBorder, lineWidth: 2))
        .background(shape.fill(Color.inkBorder).offset(x: 2.5, y: 2.5))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel(for: milestone, now: entry.date))
    }


    @ViewBuilder
    private var smallView: some View {
        if let next = entry.milestones.first {
            smallNextView(next)
        } else {
            smallEmptyView
        }
    }

    private func smallNextView(_ next: Milestone) -> some View {
        let shape = RoundedRectangle(cornerRadius: 10)
        let label: String = daysLabel(daysUntil(next.date, from: entry.date))

        return VStack(alignment: .leading, spacing: 0) {
            smallPill("UP NEXT")

            Spacer(minLength: 6)

            // Hero countdown number
            Text(label)
                .font(fredoka(28, .bold))
                .foregroundStyle(Color.inkBorder)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 6)

            // Framed milestone title and date
            VStack(alignment: .leading, spacing: 2) {
                Text(next.title)
                    .font(fredoka(12, .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.inkBorder)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(next.date, format: .dateTime.day().month(.wide))
                    .font(fredoka(11, .semibold))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.widgetAmber)
            .clipShape(shape)
            .overlay(shape.stroke(Color.inkBorder, lineWidth: 2))
            .background(shape.fill(Color.inkBorder).offset(x: 2.5, y: 2.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel(for: next, now: entry.date))
    }

    // Shown when all semester milestones have passed
    private var smallEmptyView: some View {
        VStack(alignment: .leading, spacing: 6) {
            smallPill("SEMESTER")

            Spacer()

            Text("All wrapped!")
                .font(fredoka(20, .bold))
                .foregroundStyle(Color.textPrimary)

            Text("No milestones left this semester.")
                .font(fredoka(12, .regular))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func smallPill(_ title: String) -> some View {
        Text(title)
            .font(fredoka(10, .bold))
            .foregroundStyle(Color.inkBorder)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.widgetMint)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.inkBorder, lineWidth: 1.5))
    }
}

struct ImportantDatesWidget: Widget {
    let kind = "ImportantDatesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ImportantDatesProvider()) { entry in
            ImportantDatesWidgetView(entry: entry)
                .containerBackground(Color.widgetCream, for: .widget)
        }
        .configurationDisplayName("Important dates")
        .description("Countdowns to census, breaks and other semester milestones.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    ImportantDatesWidget()
} timeline: {
    ImportantDatesEntry(date: .now, milestones: upcomingMilestones(from: Milestone.all, now: .now))
}
