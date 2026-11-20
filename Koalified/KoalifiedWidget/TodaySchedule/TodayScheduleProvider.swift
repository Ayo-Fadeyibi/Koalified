//
//  TodayScheduleProvider.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

//
//  ImportantDatesProvider.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import WidgetKit
import SwiftData


struct TodayScheduleProvider: TimelineProvider{
    
    private var sampleEntry: TodayScheduleEntry{
        TodayScheduleEntry(date: .now, classes: [ClassSnapshot(courseCode: "COMP3400", typeLabel: "Tutorial", start: .now.addingTimeInterval(20 * 60), end: .now.addingTimeInterval(80 * 60), room: "18-026", building: "Advanced Engineering"), ClassSnapshot(courseCode: "COMP3506", typeLabel: "Lecture", start: .now.addingTimeInterval(40 * 60), end: .now.addingTimeInterval(50 * 60), room: "72-322", building: "Andrew Liveris")])
    }
    
    private func loadSessions() -> [ClassSession] {
        let context = ModelContext(AppStore.container)
        return (try? context.fetch(FetchDescriptor<ClassSession>())) ?? []
    }
    
    
    func placeholder(in context: Context) -> TodayScheduleEntry {
        return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodayScheduleEntry) -> Void) {
        completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayScheduleEntry>) -> Void) {
        let sessions = loadSessions()
        let now = Date.now
        
        let calendar = Calendar.current
        let todayMidnight = calendar.startOfDay(for: now)
        
        
        var moments: [Date] = [now]
        
        if let tomorrowMidnight = calendar.date(byAdding: .day, value: 1, to: todayMidnight) {
            moments.append(tomorrowMidnight)
        }
        
        let today = findTodaysSessions(from: sessions, now: now)
        for session in today {
            if session.start > now { moments.append(session.start) }
            if session.end > now { moments.append(session.end) }
        }
        moments = Array(Set(moments)).sorted()
        
        var entries: [TodayScheduleEntry] = []
        
        for moment in moments {
            
            var snapshot: [ClassSnapshot] = []
            
            let classesToday = findTodaysSessions(from: sessions, now: moment)
            
            for session in classesToday {
                
                snapshot.append(makeSnapshot(from: session))
                
            }
            
            entries.append(TodayScheduleEntry(date: moment, classes: snapshot))
        }
        
        completion(Timeline(entries: entries, policy: .after(moments.last ?? now)))
    }
}

