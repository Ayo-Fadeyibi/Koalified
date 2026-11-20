//
//  ImportantDatesProvider.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import WidgetKit
import SwiftData


struct ImportantDatesProvider: TimelineProvider{
    
    private var sampleEntry: ImportantDatesEntry {
        ImportantDatesEntry(date: .now, milestones: upcomingMilestones(from: Milestone.all, now: .now))
    }

    
    
    func placeholder(in context: Context) -> ImportantDatesEntry {
        return sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ImportantDatesEntry) -> Void) {
        completion(sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ImportantDatesEntry>) -> Void) {
        let now = Date.now
        let calendar = Calendar.current
        let todayMidnight = calendar.startOfDay(for: now)    // Fri 20 Nov 12:00am

        var moments: [Date] = [now]                          // Fri 1:03pm
        for i in 1...7 {
            if let midnight = calendar.date(byAdding: .day, value: i, to: todayMidnight) {
                moments.append(midnight)                     // Sat, Sun, Mon... 12:00am
            }
        }
        
        let entries = moments.map { moment in
            ImportantDatesEntry(date: moment,
                                milestones: upcomingMilestones(from: Milestone.all, now: moment))
        }

        completion(Timeline(entries: entries, policy: .after(moments.last ?? now)))

    }
    
}
