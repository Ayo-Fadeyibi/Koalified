//
//  WeekGridView.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// A weekly timetable: one column per day (Mon–Fri, plus the weekend when it has classes) and one row per hour,
/// with each class drawn as a coloured block where it starts. "Day view" switches to a date strip and
/// an open timeline for a single day.
/// The week controls stay fixed at the top; the grid and the optional `footer` below it scroll.
struct WeekGridView: View {
    @Query private var sessions: [ClassSession]

    /// Any date inside the week (or day) being shown; moved with the chevrons.
    @State private var anchor: Date = .now
    @State private var isDayView = false

    private let rowHeight: CGFloat = 56
    private let lineWidth: CGFloat = 2
    private let timeColumnWidth: CGFloat = 52

    /// The date maths for what's on screen (see `TimetableWeek`).
    private var week: TimetableWeek {
        TimetableWeek(sessions: sessions, anchor: anchor, isDayView: isDayView)
    }

    private func shift(_ direction: Int) {
        anchor = week.shiftedAnchor(by: direction)
    }
    
    @State private var selectedSession: ClassSession?
    
    @State private var selectedDate: Date = .now
    
    @State private var path = NavigationPath()
    
    let options = ["Week", "Day"]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Header: < Week 5 · 19–23 October >
//            HStack {
//                
//                Button { shift(-1) } label: {
//                    Image(systemName: "chevron.left")
//                        .frame(width: 40, height: 40)
//                        .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: 10)
//                }
//
//                Spacer()
//                
//                Text(verbatim: week.title)
//                    .font(.fredoka(.headline, .bold))
//                    
//                
//                Spacer()
//                
//                Button { shift(1) } label: {
//                    Image(systemName: "chevron.right")
//                        .frame(width: 40, height: 40)
//                        .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: 10)
//                }
//
//            }
//            .sensoryFeedback(.impact(weight: .light), trigger: anchor)
//            .font(.body.weight(.bold))
//            .foregroundStyle(Color.textPrimary)
//            .buttonStyle(.plain)
//            .padding(5)
//            .background(Color.cardSurface)
//            .plainStyling()

            // Mode label and switchd
            HStack {
                
                PopoverDatePicker(selection: $anchor)

                Spacer()
                
                // The picker works in option names, so map "Day"/"Week" onto `isDayView`
                NeoSegmentedPicker(
                    options: options,
                    selection: Binding(
                        get: { isDayView ? "Day" : "Week" },
                        set: { isDayView = $0 == "Day" }
                    )
                ).frame(width: 150)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isDayView)

            if isDayView {
                dayStrip
            }

            // Only the timetable (and whatever follows it) scrolls
            ScrollView {
                VStack(spacing: 16) {
                    if isDayView {
                        dayTimeline
                    } else {
                        grid
                    }

                    // Lets the last item scroll clear of the tab bar
                    Color.clear.frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        // Wrapped in a stack so the details view's "Edit" toolbar button shows.
        .sheet(item: $selectedSession) { session in
            NavigationStack {
                SessionDetailsView(session: session)
            }
            // Set on the sheet's root, not inside the stack: from inside, the detent can be lost
            // when the sheet is re-presented for another class, and it opens full height instead.
            .presentationDetents([.height(450)])
            .sheetBorder()
        }
    }

    private var grid: some View {
        VStack(spacing: 0) {
            // Column titles
            HStack(spacing: 0) {
                headerCell(weekday: "", dayNumber: "").frame(width: timeColumnWidth + lineWidth)
                ForEach(week.days, id: \.self) { day in
                    headerCell(weekday: day.formatted(.dateTime.weekday(.abbreviated)).uppercased(), dayNumber: day.formatted(.dateTime.day()),
                               highlighted: week.isToday(day))
                }
            }
            .background(Color.cardSurface)

            // Hours and days
            HStack(alignment: .top, spacing: lineWidth) {
                timeColumn
                ForEach(week.days, id: \.self) { day in
                    dayColumn(day)
                }
            }
            .padding(lineWidth)
            .background(Color.cardBorder)
        }
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.inkBorder, lineWidth: lineWidth))
    }

    private func headerCell(weekday text: String, dayNumber number: String, highlighted: Bool = false) -> some View {
        VStack {
            Text(verbatim: text)
                .font(.fredoka(.footnote, .semibold))
                .foregroundStyle(highlighted ? Color.mintFill : Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
            
            Text(verbatim: number)
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(highlighted ? Color.mintFill : Color.textPrimary)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity)
                
        }
        
        
    }

    private var timeColumn: some View {
        VStack(spacing: lineWidth) {
            ForEach(week.hours, id: \.self) { hour in
                Text(verbatim: "\(hour):00")
                    .font(.fredoka(.footnote, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: timeColumnWidth, height: rowHeight)
                    .background(Color.cardSurface)
            }
        }
    }

    private var hourHeight: CGFloat { rowHeight + lineWidth }

    /// Height on the grid for a span of time, never shorter than a tappable sliver.
    private func blockHeight(from start: Date, to end: Date) -> CGFloat {
        max(end.timeIntervalSince(start) / 3600 * hourHeight - lineWidth, 24)
    }

    /// One day: an empty cell per hour, with that day's classes laid over them at their start time.
    /// Overlapping classes are drawn together as one cluster (see `clusterView`).
    private func dayColumn(_ day: Date) -> some View {
        let week = week
        // Today's column is tinted so it stands out from the rest of the week
        let cellColor = week.isToday(day) ? Color.tintMint : Color.cardSurface

        return ZStack(alignment: .topLeading) {
            VStack(spacing: lineWidth) {
                ForEach(week.hours, id: \.self) { _ in
                    Rectangle().fill(cellColor).frame(height: rowHeight)
                }
            }

            ForEach(week.clusters(on: day)) { cluster in
                let firstHour = week.hours.first ?? 9
                let topOfGrid = TimetableWeek.calendar.date(bySettingHour: firstHour, minute: 0, second: 0, of: day) ?? day

                clusterView(cluster)
                    .frame(height: blockHeight(from: cluster.start, to: cluster.end))
                    .offset(y: cluster.start.timeIntervalSince(topOfGrid) / 3600 * hourHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Day view

    /// Mon–Sun of the shown week. The chosen day is highlighted, days with classes get a dot,
    /// and tapping a day shows it.
    private var dayStrip: some View {
        let week = week

        return HStack(spacing: 4) {
            ForEach(week.weekDays, id: \.self) { day in
                let isSelected = TimetableWeek.calendar.isDate(day, inSameDayAs: anchor)

                Button { anchor = day } label: {
                    VStack(spacing: 4) {
                        Text(verbatim: day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.fredoka(.footnote))
                            .foregroundStyle(Color.textSecondary)

                        Text(verbatim: day.formatted(.dateTime.day()))
                            .font(.fredoka(.title2, .bold))
                            .foregroundStyle(week.isToday(day) && !isSelected ? Color.mintFill : Color.textPrimary)

                        Circle()
                            .fill(week.sessions(on: day).isEmpty ? Color.clear : Color.mintFill)
                            .frame(width: 6, height: 6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.tintMint : Color.clear, in: RoundedRectangle(cornerRadius: 14))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// The chosen day as an open timeline: an hour label and a thin line for each hour,
    /// with the day's classes laid across them.
    private var dayTimeline: some View {
        let week = week
        let day = week.days.first ?? anchor
        let firstHour = week.hours.first ?? 9
        let topOfGrid = TimetableWeek.calendar.date(bySettingHour: firstHour, minute: 0, second: 0, of: day) ?? day
        // One more line than there are hours, to close off the last one
        let lineHours = week.hours + [(week.hours.last ?? firstHour) + 1]

        return ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(lineHours, id: \.self) { hour in
                    // Each hour's line sits at the top of its slot, with the label centred on it.
                    // Overlays don't affect layout, so the slots stay exactly `hourHeight` apart.
                    Color.clear
                        .frame(height: hour == lineHours.last ? 0 : hourHeight)
                        .overlay(alignment: .top) {
                            HStack(spacing: 0) {
                                Text(verbatim: "\(hour):00")
                                    .font(.fredoka(.footnote))
                                    .foregroundStyle(Color.textSecondary)
                                    .frame(width: timeColumnWidth, alignment: .leading)

                                Rectangle()
                                    .fill(Color.cardBorder)
                                    .frame(height: 1)
                            }
                            .alignmentGuide(.top) { $0[VerticalAlignment.center] }
                        }
                }
            }

            ForEach(week.clusters(on: day)) { cluster in
                clusterView(cluster)
                    .frame(height: blockHeight(from: cluster.start, to: cluster.end))
                    .padding(.leading, timeColumnWidth)
                    .offset(y: cluster.start.timeIntervalSince(topOfGrid) / 3600 * hourHeight + lineWidth / 2)
            }
        }
        // Room for the first and last labels, which hang half above and below their lines
        .padding(.vertical, 12)
    }

    /// A class in the day view: a light wash of the course colour with a solid accent bar,
    /// the course code, and the type and length. Adds the location when the block has room.
    private func dayCard(_ session: ClassSession, isClash: Bool) -> some View {
        let accent = session.course?.color.color ?? Color.mintFill
        let detail = "\(session.type.localizedName) · \(Duration.seconds(session.end.timeIntervalSince(session.start)).formatted(.units(allowed: [.hours, .minutes], width: .narrow)))"

        return HStack(alignment: .top, spacing: 10) {
            Capsule()
                .fill(accent)
                .frame(width: 5)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 6)

            ViewThatFits(in: .vertical) {
                VStack(alignment: .leading, spacing: 2) {
                    dayCardTitle(session)
                    Text(verbatim: detail)
                    if let location = session.locationText {
                        Text(verbatim: location)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    dayCardTitle(session)
                    Text(verbatim: detail)
                }
                dayCardTitle(session)
            }
            .font(.fredoka(.subheadline))
            .foregroundStyle(Color.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.vertical, 5)

            Spacer(minLength: 0)
        }
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(accent.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            if isClash {
                RoundedRectangle(cornerRadius: 14).strokeBorder(Color.redFill, lineWidth: 2)
            }
        }
    }

    private func dayCardTitle(_ session: ClassSession) -> some View {
        Text(verbatim: session.course?.courseCode ?? "")
            .font(.fredoka(.body, .bold))
    }

    // MARK: - Classes

    /// A lone class, or a group of clashing ones split into equal-width lanes side by side.
    /// Each class sits at its own time inside its lane and opens its own details.
    private func clusterView(_ cluster: SessionCluster) -> some View {
        HStack(alignment: .top, spacing: 2) {
            ForEach(0..<cluster.laneCount, id: \.self) { lane in
                ZStack(alignment: .top) {
                    ForEach(cluster.lanes.filter { $0.lane == lane }, id: \.session.id) { item in
                        Button { selectedSession = item.session } label: {
                            if isDayView {
                                dayCard(item.session, isClash: cluster.laneCount > 1)
                            } else {
                                sessionCard(item.session, isClash: cluster.laneCount > 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(height: blockHeight(from: item.session.start, to: item.session.end))
                        .offset(y: item.session.start.timeIntervalSince(cluster.start) / 3600 * hourHeight)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    /// A class's coloured block in the week view. `isClash` outlines it in red when it overlaps another class.
    private func sessionCard(_ session: ClassSession, isClash: Bool) -> some View {
        let textColor = session.course?.color.onColor ?? Color.white
        let fillColor: Color = session.course?.color.color ?? Color.tintMint

        return VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: session.course?.courseCode ?? "")
                .font(.fredoka(.caption, .bold))
            Text(session.type.label)
                .font(.fredoka(.caption))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(textColor)
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(fillColor, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isClash ? Color.redFill : Color.inkBorder, lineWidth: isClash ? 3 : 2)
        )
    }
}

#Preview {
    WeekGridView()
        .padding()
        .background(Color.screenBackground)
    .modelContainer(PreviewData.container)
}
#Preview("Clashes") {
    WeekGridView()
        .padding()
        .background(Color.screenBackground)
        .modelContainer(PreviewData.clashContainer)
}

