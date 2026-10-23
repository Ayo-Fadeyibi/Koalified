import SwiftUI

enum OnboardingStep: Hashable {
    case language, university, year, timetableHelp, findLink, importTimetable
}

struct OnboardingFlow: View {
    @State private var path: [OnboardingStep] = []
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(onNext: { path.append(.language) })
                .navigationDestination(for: OnboardingStep.self) { step in
                    Group {
                        switch step {
                        case .language:
                            LanguageView(onNext: { path.append(.university) })
                        case .university:
                            UniversityView(onNext: { path.append(.year) })
                        case .year:
                            YearView(onNext: { isFirstYear in
                                if isFirstYear { path.append(.timetableHelp) } else { finish() }
                            })
                        case .timetableHelp:
                            TimetableHelpView(
                                onShowMe: { path.append(.findLink) },
                                onHaveIt: { path.append(.importTimetable) }
                            )
                        case .findLink:
                            FindLinkView(onImport: { path.append(.importTimetable) })
                        case .importTimetable:
                            ImportTimetableView(onDone: { finish() })
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                finish()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.footnote.weight(.bold))
                                    .foregroundStyle(Color.inkSecondary)
                            }
                        }
                    }
                }
        }
    }

    // Marks onboarding as complete. RootView will then show the main tabs.
    private func finish() {
        hasOnboarded = true
    }
}

#Preview {
    OnboardingFlow()
}
