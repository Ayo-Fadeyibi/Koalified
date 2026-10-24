import SwiftUI
import SwiftData

@main struct KoalifiedApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [Course.self, ClassSession.self, AssessmentItem.self])
        }
    }
}
