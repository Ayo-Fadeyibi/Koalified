import SwiftUI
import SwiftData

/// App entry point. Hosts `RootView` with the shared model container.
@main struct KoalifiedApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenComic") private var hasSeenComic = false
    @State private var showSplash = true

    init() {
        // Use Fredoka in tab bar labels, segmented pickers and navigation titles.
        Fredoka.applyAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            // The ZStack gives the transitions a container to animate in; without one the swap can just jump.
            ZStack {
                // Solid backdrop so the window colour never shows through mid cross-fade.
                Color.canvas.ignoresSafeArea()

                if hasSeenComic {
                    RootView()
                        .modelContainer(AppStore.container)
                        // Re-sync notifications and widget data whenever the app becomes active.
                        .onChange(of: scenePhase) { _, phase in
                            if phase == .active {
                                AppSync.dataChanged(in: AppStore.container.mainContext)
                            }
                        }
                        .transition(.opacity)
                } else if showSplash {
                    SplashView { showSplash = false }
                        .transition(.opacity)
                } else {
                    OnboardingComicView(onFinish: { hasSeenComic = true })
                        .transition(.opacity)
                }
            }
            // Animate the swaps here, on the container. A bare withAnimation around an
            // @AppStorage write doesn't reliably carry the animation into a view swap.
            .animation(.easeInOut(duration: 0.7), value: showSplash)
            .animation(.easeInOut(duration: 0.7), value: hasSeenComic)
        }
    }
}
