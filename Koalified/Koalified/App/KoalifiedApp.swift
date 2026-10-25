import SwiftUI
import SwiftData

@main struct KoalifiedApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(AppStore.container)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        AppSync.dataChanged(in: AppStore.container.mainContext)
                    }
                }
        }
    }
}
