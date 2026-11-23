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

    /// One day: an empty cell per hour, with that day's classes laid over them at their start time.
    private func dayColumn(_ day: Date) -> some View {
        let hourHeight = rowHeight + lineWidth
        let week = week

        return ZStack(alignment: .topLeading) {
            VStack(spacing: lineWidth) {
                ForEach(week.hours, id: \.self) { _ in
                    Rectangle().fill(Color.cardSurface).frame(height: rowHeight)
                }
            }

            ForEach(week.sessions(on: day)) { session in
                let startMinutes = week.startMinutes(of: session)
                let length = week.durationHours(of: session)

                sessionBlock(session)
                    .frame(height: max(length * hourHeight - lineWidth, 24))
                    .offset(y: CGFloat(startMinutes) / 60 * hourHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionBlock(_ session: ClassSession) -> some View {
        NavigationLink(value: session) {
            
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: session.course?.courseCode ?? "")
                    .font(.fredoka(.caption, .bold))
                    .foregroundStyle(Color.white)
                
                Text(session.type.label)
                    .font(.fredoka(.caption))
                    .foregroundStyle(Color.white)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .foregroundStyle(Color.textPrimary)
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(session.course?.color.color ?? Color.tintMint, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(session.clashable == true ? Color.redFill
                                  : Color.inkBorder, lineWidth:session.clashable == true ? 6 : 2)
            )
            
        }.buttonStyle(.plain)
    }
    
}

#Preview {
    WeekGridView()
        .padding()
        .background(Color.screenBackground)
    .modelContainer(PreviewData.container)
}
