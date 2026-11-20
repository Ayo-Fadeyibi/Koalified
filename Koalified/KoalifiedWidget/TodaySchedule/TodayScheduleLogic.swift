//
//  TodayScheduleLogic.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 20/11/2026.
//

import Foundation

enum RowState {
    case done, now, next, later
}

func rowState(of session: ClassSnapshot, in classes: [ClassSnapshot], at date: Date) -> RowState {
    if session.end <= date {
        return .done
    }
    
    if session.start <= date && date < session.end{
        return .now
    }
    
    let nextStart = classes.filter { $0.start > date }.map(\.start).min()
    if session.start == nextStart { return .next }
    return .later
    
}

/// Picks which rows fit in the widget. Finished classes are dropped first to make room for
/// upcoming ones; `firstHiddenSession` is the earliest upcoming class that didn't fit.
func visibleRows(from classes: [ClassSnapshot], at date: Date, limit: Int = 5)
-> (rows: [ClassSnapshot], hiddenUpcoming: Int, firstHiddenSession: ClassSnapshot?) {

    if classes.count <= limit {
        return (classes, 0, nil)
    }

    let finished = classes.filter { $0.end <= date }
    let remaining = classes.filter { $0.end > date }

    if remaining.count >= limit {
        let hidden = Array(remaining.dropFirst(limit))
        return (Array(remaining.prefix(limit)), hidden.count, hidden.first)
    }

    let earlyFinish = Array(finished.suffix(limit - remaining.count))
    return (earlyFinish + remaining, 0, nil)
}
