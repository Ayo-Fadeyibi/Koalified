//
//  AppStore.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftData
import Foundation

enum AppStore {
    static let groupID = "group.com.ayooluwafadeyibipersonalteam.Koalified"

    static let schema = Schema([
        Course.self, ClassSession.self, AssessmentItem.self
    ])

    static let container: ModelContainer = {
        let config = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(groupID),
            cloudKitDatabase: .none
        )
        print("Store at:", config.url.path)
        return try! ModelContainer(for: schema, configurations: config)
    }()
}
