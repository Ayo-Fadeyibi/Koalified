import WidgetKit
import SwiftUI
import SwiftData

struct CountEntry: TimelineEntry {
    let date: Date
    let courseCount: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountEntry {
        CountEntry(date: .now, courseCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountEntry>) -> Void) {
        let next = Date().addingTimeInterval(60 * 60)
        completion(Timeline(entries: [makeEntry()], policy: .after(next)))
    }

    private func makeEntry() -> CountEntry {
        let context = ModelContext(AppStore.container)
        let count = (try? context.fetchCount(FetchDescriptor<Course>())) ?? 0
        return CountEntry(date: .now, courseCount: count)
    }
}

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
