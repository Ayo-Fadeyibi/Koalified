//
//  WeekGridView.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// A weekly timetable: one column per day (Mon–Fri, plus the weekend when it has classes) and one row per hour,
/// with each class drawn as a mint block where it starts. "Day view" switches to a single day.
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
    
    @State private var path = NavigationPath()

    /// The clashing classes listed in the sheet, after tapping a stack in week view.
    @State private var clashGroup: SessionCluster?
    /// The class picked in that sheet, opened once the sheet has closed.
    @State private var pendingSession: ClassSession?

    /// How far each class in a week-view clash stack sits to the right of the one beneath it.
    private let stackStep: CGFloat = 6

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Header: < Week 5 · 19–23 October >
            HStack {
                
                Button { shift(-1) } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 40, height: 40)
                        .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall)
                }

                Spacer()
                
                Text(verbatim: week.title)
                    .font(.fredoka(.headline, .bold))
                
                Spacer()
                
                Button { shift(1) } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 40, height: 40)
                        .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: Layout.radiusSmall)
                }

            }
            // `anchor` changes on every chevron tap, so each shift plays one haptic.
            .sensoryFeedback(.impact(weight: .light), trigger: anchor)
            .font(.body.weight(.bold))
            .foregroundStyle(Color.textPrimary)
            .buttonStyle(.plain)
            .padding(.bottom, 10)

            // Mode label and switch
            HStack {
                
                Label(isDayView ? "DAY" : "WEEK", systemImage: "dot.square")
                    .font(.fredoka(.headline, .bold))
                    .foregroundStyle(isDayView ? Color.accent : Color.courseAmber)
                Spacer()
                
                Button{
                    isDayView.toggle();
    
                } label: {
                    
                    Text(isDayView ? "Week view" : "Day view")
                        .font(.fredoka(.body, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .neoBrutalist(
                            backgroundColor: isDayView ? Color.tintMint : Color.tintAmber,
                            cornerRadius: Layout.radiusSmall
                        )
                    
                }.sensoryFeedback(.impact(weight: .light), trigger: isDayView)
                
            }

            // Only the timetable (and whatever follows it) scrolls
            ScrollView {
                VStack(spacing: 16) {
                    grid

                    // Lets the last item scroll clear of the tab bar
                    Color.clear.frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .sheet(item: $clashGroup, onDismiss: {
            selectedSession = pendingSession
            pendingSession = nil
        }) { cluster in
            ClashListSheet(sessions: cluster.sessions) { pendingSession = $0 }
                .sheetBorder()
                .presentationDetents([.medium])
        }
        .navigationDestination(item: $selectedSession) { session in
            SessionDetailsView(session: session)
        }
    }

    private var grid: some View {
        VStack(spacing: 0) {
            // Column titles
            HStack(spacing: 0) {
                headerCell("TIME").frame(width: timeColumnWidth + lineWidth)
                ForEach(week.days, id: \.self) { day in
                    headerCell(day.formatted(.dateTime.weekday(.abbreviated)).uppercased(),
                               highlighted: week.isToday(day))
                }
            }
            .background(Color.inkBorder)

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
        .overlay(Rectangle().strokeBorder(Color.inkBorder, lineWidth: lineWidth))
    }

    private func headerCell(_ text: String, highlighted: Bool = false) -> some View {
        Text(verbatim: text)
            .font(.fredoka(.footnote, .bold))
            .foregroundStyle(highlighted ? Color.mintFill : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
    }

    private var timeColumn: some View {
        VStack(spacing: lineWidth) {
            ForEach(week.hours, id: \.self) { hour in
                Text(verbatim: "\(hour):00")
                    .font(.fredoka(.footnote, .bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: timeColumnWidth, height: rowHeight)
                    .background(Color.tintAmber.opacity(0.4))
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

        return ZStack(alignment: .topLeading) {
            VStack(spacing: lineWidth) {
                ForEach(week.hours, id: \.self) { _ in
                    Rectangle().fill(Color.cardSurface).frame(height: rowHeight)
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

    /// A lone class, or a group of clashing ones:
    /// - Day view: side-by-side lanes, each class opening on its own.
    /// - Week view: a fanned stack (or one "N classes" block for three or more) that opens a list of the clash.
    @ViewBuilder
    private func clusterView(_ cluster: SessionCluster) -> some View {
        if !cluster.isClash, let session = cluster.sessions.first {
            NavigationLink(value: session) {
                sessionCard(session, detailed: isDayView)
            }
            .buttonStyle(.plain)
        } else if isDayView {
            dayLanes(cluster)
        } else {
            Button { clashGroup = cluster } label: {
                if cluster.lanes.count >= 3 {
                    collapsedClash(cluster)
                } else {
                    // Bottom corner, clear of the course code at the top.
                    stackedClash(cluster)
                        .overlay(alignment: .bottomTrailing) { clashBadge(cluster.lanes.count) }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("\(cluster.lanes.count) classes clash"))
        }
    }

    /// Day view: the cluster split into equal-width lanes, with each class placed at its time inside its lane.
    private func dayLanes(_ cluster: SessionCluster) -> some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(0..<cluster.laneCount, id: \.self) { lane in
                ZStack(alignment: .top) {
                    ForEach(cluster.lanes.filter { $0.lane == lane }, id: \.session.id) { item in
                        NavigationLink(value: item.session) {
                            sessionCard(item.session, detailed: true)
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

    /// Week view, two lanes: each class nudged right of the one beneath it, like a fanned stack of tickets.
    private func stackedClash(_ cluster: SessionCluster) -> some View {
        ZStack(alignment: .top) {
            ForEach(cluster.lanes, id: \.session.id) { item in
                sessionCard(item.session, detailed: false)
                    .frame(height: blockHeight(from: item.session.start, to: item.session.end))
                    .padding(.leading, CGFloat(item.lane) * stackStep)
                    .padding(.trailing, CGFloat(cluster.laneCount - 1 - item.lane) * stackStep)
                    .offset(y: item.session.start.timeIntervalSince(cluster.start) / 3600 * hourHeight)
                    .zIndex(Double(item.lane))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// Week view, three or more lanes: one striped block covering the whole clash.
    private func collapsedClash(_ cluster: SessionCluster) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: "\(cluster.lanes.count)")
                .font(.fredoka(.caption, .bold))
            Text("classes")
                .font(.fredoka(.caption))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(Color.textPrimary)
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            // A colour stripe per class along the bottom, so the courses involved stay recognisable.
            VStack(spacing: 0) {
                Color.cardSurface
                HStack(spacing: 0) {
                    ForEach(cluster.sessions) { session in
                        session.course?.color.color ?? Color.tintMint
                    }
                }
                .frame(height: 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.redFill, lineWidth: 3))
    }

    /// The little red count on the corner of a week-view clash.
    private func clashBadge(_ count: Int) -> some View {
        Text(verbatim: "\(count)")
            .font(.fredoka(.caption2, .bold))
            .foregroundStyle(Color.white)
            .frame(width: 18, height: 18)
            .background(Color.redFill, in: Circle())
            .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 1.5))
            .offset(x: 5, y: 5)
            .zIndex(1)
    }

    /// A class's coloured block. `detailed` (day view, where there's room) adds the building and room.
    private func sessionCard(_ session: ClassSession, detailed: Bool) -> some View {
        let textColor = session.course?.color.onColor ?? Color.white

        return Group {
            if detailed {
                // Show as much as the block's height allows: everything, then a tighter layout, then just the class.
                ViewThatFits(in: .vertical) {
                    VStack(alignment: .leading, spacing: 2) {
                        classTitle(session)
                        if let building = session.building, !building.isEmpty {
                            Label(building, systemImage: "building.2.fill")
                        }
                        if let room = session.room, !room.isEmpty {
                            Label(room, systemImage: "door.left.hand.open")
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        classTitle(session)
                        if let location = session.locationText {
                            Text(verbatim: location)
                        }
                    }
                    classTitle(session)
                }
                .labelStyle(SessionLocationLabelStyle())
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: session.course?.courseCode ?? "")
                        .font(.fredoka(.caption, .bold))
                    Text(session.type.label)
                        .font(.fredoka(.caption))
                }
            }
        }
        .font(.fredoka(.caption))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(textColor)
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(session.course?.color.color ?? Color.tintMint, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(session.clashable == true ? Color.redFill
                              : Color.inkBorder, lineWidth:session.clashable == true ? 6 : 2)
        )
    }

    /// "CSSE1001 Lecture" on one line, for the day view.
    private func classTitle(_ session: ClassSession) -> some View {
        HStack(spacing: 4) {
            Text(verbatim: session.course?.courseCode ?? "")
                .font(.fredoka(.caption, .bold))
            Text(session.type.label)
                .font(.fredoka(.caption))
        }
    }
    
}

/// A small icon tight against its text, for the building and room lines in a day-view class block.
private struct SessionLocationLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .font(.caption2)
                .frame(width: 14)
            configuration.title
        }
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

