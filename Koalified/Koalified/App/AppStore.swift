//
//  AppStore.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftData
import Foundation

/// Namespace for the SwiftData storage shared between the app and its widget extension.
enum AppStore {
    /// App Group identifier; lets the widget read the same database as the app.
    static let groupID = "group.com.ayooluwafadeyibipersonalteam.Koalified"

    /// The SwiftData models persisted by the app.
    static let schema = Schema([
        Course.self, ClassSession.self, AssessmentItem.self
    ])

    /// The single shared model container, stored in the App Group container with CloudKit off.
    /// Crashes on launch if the store cannot be created, since the app cannot run without it.
    static let container: ModelContainer = {
        let config = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(groupID),
            cloudKitDatabase: .none
        )
        return try! ModelContainer(for: schema, configurations: config)
    }()
}
