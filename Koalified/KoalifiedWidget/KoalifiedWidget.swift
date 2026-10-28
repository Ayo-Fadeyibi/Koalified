import WidgetKit
import SwiftUI
import SwiftData

/// The data the widget shows at one point in time: how many courses exist.
struct CountEntry: TimelineEntry {
    let date: Date
    let courseCount: Int
}

/// Supplies the widget with entries read from the shared database.
struct Provider: TimelineProvider {
    /// Dummy entry shown while the widget loads.
    func placeholder(in context: Context) -> CountEntry {
        CountEntry(date: .now, courseCount: 0)
    }

    /// Entry used in the widget gallery and transient previews.
    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> Void) {
        completion(makeEntry())
    }

    /// One current entry; WidgetKit asks again after an hour (the app also forces a reload when data changes).
    func getTimeline(in context: Context, completion: @escaping (Timeline<CountEntry>) -> Void) {
        let next = Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [makeEntry()], policy: .after(next)))
    }

    /// Counts the courses in the App Group database.
    private func makeEntry() -> CountEntry {
        let context = ModelContext(AppStore.container)
        let count = (try? context.fetchCount(FetchDescriptor<Course>())) ?? 0
        return CountEntry(date: .now, courseCount: count)
    }
}

/// Small home screen widget that shows the number of courses.
struct KoalifiedWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KoalifiedWidget", provider: Provider()) { entry in
            VStack {
                Text("\(entry.courseCount)").font(.largeTitle.bold())
                Text("courses")
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Courses")
        .supportedFamilies([.systemSmall])
    }
}
