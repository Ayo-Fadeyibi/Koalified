import WidgetKit
import SwiftData


struct NextClassProvider: TimelineProvider{
    
    private var sampleEntry: NextClassEntry = NextClassEntry(date: .now, next: ClassSnapshot(courseCode: "COMP3400", typeLabel: "Tutorial", start: .now.addingTimeInterval(20 * 60), end: .now.addingTimeInterval(80 * 60), room: "18-026", building: "Advanced Engineering"))
    
    private func loadSessions() -> [ClassSession] {
        let context = ModelContext(AppStore.container)
        return (try? context.fetch(FetchDescriptor<ClassSession>())) ?? []
    }
    
    
    func placeholder(in context: Context) -> NextClassEntry {
        return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextClassEntry) -> Void) {
        completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextClassEntry>) -> Void) {
        let sessions = loadSessions()
        let now = Date.now

        // Step 1: the classes still to come today
        let upcoming = findUpcomingSessions(from: sessions, now: now)

        // Step 2: the moments when the widget should change
        var moments: [Date] = [now]
        for session in upcoming {
            if session.start > now { moments.append(session.start) }
            if session.end > now { moments.append(session.end) }
        }
        moments.sort()

        // Step 3: one entry for each moment
        var entries: [NextClassEntry] = []
        for moment in moments {
            let classesLeft = findUpcomingSessions(from: sessions, now: moment)
            let snapshot = classesLeft.first.map(makeSnapshot)   // nil if nothing is left
            entries.append(NextClassEntry(date: moment, next: snapshot))
        }

        // Step 4: when to ask for a fresh timeline
        let refreshDate: Date
        if let last = moments.last, last > now {
            refreshDate = last
        } else {
            // Nothing left today: refresh after midnight
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: now)
            refreshDate = calendar.date(byAdding: .day, value: 1, to: today) ?? now.addingTimeInterval(3600)
        }

        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}
