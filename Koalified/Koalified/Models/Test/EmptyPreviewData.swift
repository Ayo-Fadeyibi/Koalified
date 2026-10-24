//
//  EmptyPreviewData.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/10/2026.
//

import SwiftData
import Foundation

@MainActor
enum EmptyPreviewData {
    static let container: ModelContainer = {
        let container = try! ModelContainer(
            for: Course.self, ClassSession.self, AssessmentItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        return container
    }()
}
