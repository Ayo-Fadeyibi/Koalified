import SwiftUI
import SwiftData

/// App entry point. Hosts `RootView` with the shared model container.
@main struct KoalifiedApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenComic") private var hasSeenComic = false

    init() {
        // Use Fredoka in tab bar labels, segmented pickers and navigation titles.
        Fredoka.applyAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenComic {
                RootView()
                    .modelContainer(AppStore.container)
                    // Re-sync notifications and widget data whenever the app becomes active.
                    .onChange(of: scenePhase) { _, phase in
                        if phase == .active {
                            AppSync.dataChanged(in: AppStore.container.mainContext)
                        }
                    }
            } else {
                withAnimation {
                    OnboardingComicView(onFinish: {hasSeenComic = true})
                }
            }
        }
    }
}
