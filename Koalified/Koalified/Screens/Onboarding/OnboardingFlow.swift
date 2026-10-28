import SwiftUI

//This contains all the screen that appears in the onboarding
enum OnboardingStep: Hashable {
    case language, university, year, timetableHelp, findLink, importTimetable
}

/*
 This view handles the flow of the onboarding, it decides which screen comes before and next by using a switch case. Basically it keeps track which screen needs to be displayed and not during the onboarding with the WelcomeView as the root/start.
 */
struct OnboardingFlow: View {
    /// The screens pushed on top of WelcomeView, in order.
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
                    .closeButton {
                        finish()
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
