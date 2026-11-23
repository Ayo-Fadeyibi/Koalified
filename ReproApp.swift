// Minimal repro for: pushed destination driven only by @AppStorage stops redrawing
// after an ancestor that reads the same key re-renders.
// Create a new iOS App project, replace its App file with this file, and run.

import SwiftUI

@main
struct ReproApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

/// Reads the same key as the settings screen, so it re-renders on every change.
struct RootView: View {
    @AppStorage("language") private var languageCode = "en"

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    NavigationLink("Open Profile", value: ProfileRoot())
                        .navigationDestination(for: ProfileRoot.self) { _ in ProfileView() }
                }
            }
        }
        .environment(\.locale, Locale(identifier: languageCode))
    }
}

struct ProfileRoot: Hashable {}
enum ProfileDestination: Hashable { case language }

/// A pushed screen that registers its own destinations.
struct ProfileView: View {
    var body: some View {
        List {
            NavigationLink("Language", value: ProfileDestination.language)
        }
        .navigationDestination(for: ProfileDestination.self) { _ in
            LanguageSettingsView()
        }
    }
}

struct LanguageSettingsView: View {
    @AppStorage("language") private var languageCode = "en"
    // WORKAROUND: uncomment this unused @State and the bug disappears.
    // @State private var unused = 0

    private let codes = ["en", "ko", "ja", "hi", "id"]

    var body: some View {
        let _ = print("LSV body code=\(languageCode)")
        ScrollView {
            VStack(spacing: 12) {
                ForEach(codes, id: \.self) { code in
                    Row(isSelected: code == languageCode, title: code) {
                        languageCode = code
                    }
                }
            }
            .padding()
        }
    }
}

struct Row: View {
    let isSelected: Bool
    let title: String
    let action: () -> Void

    var body: some View {
        let _ = print("row body \(title) isSelected=\(isSelected)")
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected { Image(systemName: "checkmark") }
            }
            .padding()
            .background(isSelected ? Color.mint.opacity(0.3) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
