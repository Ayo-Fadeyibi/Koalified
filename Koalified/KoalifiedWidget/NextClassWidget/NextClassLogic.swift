//
//  Logic.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 18/11/2026.
//

import Foundation
import SwiftData

/// Every class session in the shared store, for the widgets' timelines.
func loadClassSessions() -> [ClassSession] {
    let context = ModelContext(AppStore.container)
    return (try? context.fetch(FetchDescriptor<ClassSession>())) ?? []
}

func makeSnapshot(from session: ClassSession) -> ClassSnapshot {
    ClassSnapshot(
        courseCode: session.course?.courseCode ?? "",
        typeLabel: session.type.localizedName,
        start: session.start,
        end: session.end,
        room: session.room,
        building: session.building
    )
}
