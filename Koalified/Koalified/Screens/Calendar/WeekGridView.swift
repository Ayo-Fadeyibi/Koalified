//
//  WeekGridView.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// A weekly timetable: one column per day (Mon–Fri, plus the weekend when it has classes) and one row per hour,
/// with each class drawn as a mint block where it starts. "Day view" switches to a single day.
/// The week controls stay fixed at the top; the grid and the optional `footer` below it scroll.
struct WeekGridView<Footer: View>: View {
    @Query private var sessions: [ClassSession]
    private let footer: Footer

    init(@ViewBuilder footer: () -> Footer) {
        self.footer = footer()
    }

    /// Any date inside the week (or day) being shown; moved with the chevrons.
    @State private var anchor: Date = .now
    @State private var isDayView = false

    private let rowHeight: CGFloat = 56
    private let lineWidth: CGFloat = 2
    private let timeColumnWidth: CGFloat = 52

    /// Monday-first, whatever the device's region says.
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }()

    // MARK: - What is shown

    private var weekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: anchor)?.start ?? calendar.startOfDay(for: anchor)
    }

    private func sessions(on day: Date) -> [ClassSession] {
        sessions.filter { calendar.isDate($0.start, inSameDayAs: day) }
    }

    /// The columns: the one chosen day, or Mon–Fri (Mon–Sun when a weekend day has a class).
    private var days: [Date] {
        if isDayView { return [calendar.startOfDay(for: anchor)] }
        let week = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let weekendHasClass = week.suffix(2).contains { !sessions(on: $0).isEmpty }
        return weekendHasClass ? week : Array(week.prefix(5))
    }

    /// The hours drawn: 9:00–17:00 at least, stretched to fit any earlier or later class.
    private var hours: [Int] {
        let shown = days.flatMap(sessions(on:))
        let first = min(9, shown.map { calendar.component(.hour, from: $0.start) }.min() ?? 9)
        let last = max(17, shown.map(endHour).max() ?? 17)
        return Array(first..<max(last, first + 1))
    }

    /// The hour a class finishes in, rounded up (a 10:30 finish ends the 10:00 row's neighbour at 11).
    private func endHour(_ session: ClassSession) -> Int {
        let hour = calendar.component(.hour, from: session.end)
        let minute = calendar.component(.minute, from: session.end)
        return minute > 0 ? hour + 1 : hour
    }

    /// Teaching week: counted from the first class of the semester the shown classes belong to.
    private var teachingWeek: Int? {
        guard let course = days.flatMap(sessions(on:)).first?.course else { return nil }
        let semester = sessions.filter { $0.course?.term == course.term && $0.course?.year == course.year }
        guard let earliest = semester.map(\.start).min(),
              let firstWeek = calendar.dateInterval(of: .weekOfYear, for: earliest)?.start else { return nil }
        let weeks = calendar.dateComponents([.weekOfYear], from: firstWeek, to: weekStart).weekOfYear ?? 0
        return weeks >= 0 ? weeks + 1 : nil
    }

    private var title: String {
        guard let first = days.first, let last = days.last else { return "" }
        if isDayView {
            return first.formatted(.dateTime.weekday(.wide).day().month(.wide))
        }
        let range: String
        if calendar.isDate(first, equalTo: last, toGranularity: .month) {
            range = "\(first.formatted(.dateTime.day()))–\(last.formatted(.dateTime.day().month(.wide)))"
        } else {
            range = "\(first.formatted(.dateTime.day().month(.abbreviated))) – \(last.formatted(.dateTime.day().month(.abbreviated)))"
        }
        return teachingWeek.map { "Week \($0) · \(range)" } ?? range
    }

    private func shift(_ direction: Int) {
        let component: Calendar.Component = isDayView ? .day : .weekOfYear
        anchor = calendar.date(byAdding: component, value: direction, to: anchor) ?? anchor
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // Header: < Week 5 · 19–23 October >
            HStack {
                Button { shift(-1) } label: { Image(systemName: "chevron.left").frame(width: 32, height: 32) }
                Spacer()
                Text(verbatim: title)
                    .font(.fredoka(.headline, .bold))
                Spacer()
                Button { shift(1) } label: { Image(systemName: "chevron.right").frame(width: 32, height: 32) }
            }
            .font(.body.weight(.bold))
            .foregroundStyle(Color.textPrimary)
            .buttonStyle(.plain)

            // Mode label and switch
            HStack {
                Label(isDayView ? "DAY" : "WEEK", systemImage: "dot.square")
                    .font(.fredoka(.headline, .bold))
                    .foregroundStyle(Color.accent)
                Spacer()
                TextButton(title: isDayView ? "Week view →" : "Day view →", color: Color.textPrimary) {
                    withAnimation(.easeInOut(duration: 0.2)) { isDayView.toggle() }
                }
            }

            // Only the timetable (and whatever follows it) scrolls
            ScrollView {
                VStack(spacing: 16) {
                    grid
                    footer

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
                ForEach(days, id: \.self) { day in
                    headerCell(day.formatted(.dateTime.weekday(.abbreviated)).uppercased(),
                               highlighted: calendar.isDateInToday(day))
                }
            }
            .background(Color.inkBorder)

            // Hours and days
            HStack(alignment: .top, spacing: lineWidth) {
                timeColumn
                ForEach(days, id: \.self) { day in
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
            ForEach(hours, id: \.self) { hour in
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
        let firstHour = hours.first ?? 9

        return ZStack(alignment: .topLeading) {
            VStack(spacing: lineWidth) {
                ForEach(hours, id: \.self) { _ in
                    Rectangle().fill(Color.cardSurface).frame(height: rowHeight)
                }
            }

            ForEach(sessions(on: day)) { session in
                let startMinutes = calendar.component(.hour, from: session.start) * 60
                    + calendar.component(.minute, from: session.start) - firstHour * 60
                let length = session.end.timeIntervalSince(session.start) / 3600

                sessionBlock(session)
                    .frame(height: max(length * hourHeight - lineWidth, 24))
                    .offset(y: CGFloat(startMinutes) / 60 * hourHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionBlock(_ session: ClassSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: session.course?.courseCode ?? "")
                .font(.fredoka(.caption, .bold))
            Text(session.type.label)
                .font(.fredoka(.caption))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .foregroundStyle(Color.textPrimary)
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.tintMint)
    }
}

#Preview {
    WeekGridView { PrimaryButton(title: "Add a class") {} }
        .padding()
        .background(Color.screenBackground)
    .modelContainer(PreviewData.container)
}
