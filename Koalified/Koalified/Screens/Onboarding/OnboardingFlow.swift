import SwiftUI

//This contains all the screens that appear in the onboarding, after the splash
enum OnboardingStep: Hashable {
    case welcome, language, importTimetable
}

/*
 This view handles the flow of the onboarding: welcome, then language, then the timetable import.
 It keeps track of which screen is showing with a switch case, starting at the WelcomeView.
 Every screen after the welcome has a back button in the toolbar that returns to the previous step.
 (UniversityView, YearView, TimetableHelpView, FindLinkView and ImportTimetableView are no longer part of the flow.)
 */
struct OnboardingFlow: View {
    @State private var step: OnboardingStep = .welcome
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        Group {
            switch step {
            case .welcome:
                WelcomeView(onNext: { step = .language })
            case .language:
                NavigationStack {
                    LanguageView(onNext: { step = .importTimetable })
                        .toolbar { OnboardingBackButton { step = .welcome } }
                        .toolbarBackground(.hidden, for: .navigationBar)
                }
            case .importTimetable:
                // The import flow finishes onboarding whether the student imports or skips.
                // It has its own NavigationStack, so it adds the back button itself.
                ImportFlowView(isOnboarding: true,
                               onFinish: { finish() },
                               onBack: { step = .language })
            }
        }
        .background(Color.screenBackground.ignoresSafeArea())
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // Marks onboarding as complete. RootView will then show the main tabs.
    private func finish() {
        hasOnboarded = true
    }
}

/// Chevron in the top-left of the navigation bar that goes back one onboarding step.
struct OnboardingBackButton: ToolbarContent {
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.accent)
            }
            .accessibilityLabel("Back")
        }
    }
}

#Preview {
    OnboardingFlow()
}
