//
//  ImportFlowView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Runs the timetable import: pick a .ics file or paste a link, choose which semesters to import,
/// check the courses, show the result.
/// This view only shows screens and moves between them; the logic lives in `ImportSession`
/// (Import/ImportSession.swift) and each screen lives in its own file.
/// Screens are pushed on a NavigationStack, so the system back button and swipe-back work.
struct ImportFlowView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    /// True when shown as the last step of onboarding (adds the step label and a skip option).
    var isOnboarding = false
    /// Called instead of dismissing when the flow ends, e.g. to finish onboarding.
    var onFinish: (() -> Void)? = nil
    /// When set, the start screen shows a back button in the toolbar (used to step back in onboarding).
    var onBack: (() -> Void)? = nil

    /// The screens that can be pushed on top of the start screen.
    private enum Route: Hashable { case chooseSemester, review, noClasses, done(ImportResult) }

    @State private var session = ImportSession()
    @State private var path: [Route] = []
    @State private var showPicker = false

    var body: some View {
        NavigationStack(path: $path) {
            ImportTimetableView(
                errorMessage: session.errorMessage,
                isOnboarding: isOnboarding,
                onImportLink: { link in Task { show(await session.loadLink(link)) } },
                onChooseFile: { showPicker = true },
                onSkip: isOnboarding ? { finish() } : nil
            )
                .screenStyle()
                .toolbar {
                    if let onBack { OnboardingBackButton(action: onBack) }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                        .screenStyle()
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        .fileImporter(isPresented: $showPicker,
                      allowedContentTypes: [.calendarEvent, .text]) { picked in
            if case .success(let url) = picked { show(session.load(url)) }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .chooseSemester:
            ChooseSemesterView(
                semesters: session.importable,
                unplacedCount: session.unplacedCount,
                selected: session.selected,
                statusFor: session.status(of:),
                onToggle: session.toggle,
                onImport: { path.append(.review) },
                onChooseDifferentFile: { showPicker = true }
            )
        case .review:
            // "Looks right" is what actually runs the import.
            FoundInTimetableView(courses: session.foundCourses(), onConfirm: runImport)
        case .noClasses:
            NoClassesFoundView(
                onChooseDifferentFile: { showPicker = true },
                onAddManually: { finish() }
            )
        case .done(let result):
            ImportDoneView(result: result) { finish() }
                .navigationBarBackButtonHidden(true)   // importing again from here would be confusing
        }
    }

    // MARK: - Navigation

    /// Moves to the screen that matches what the session found in the file or link.
    private func show(_ outcome: ImportLoadOutcome) {
        switch outcome {
        case .chooseSemester: path = [.chooseSemester]
        case .noClasses:      path = [.noClasses]
        case .failed:         path = []
        }
    }

    /// Runs the import, then shows the result and asks about reminders.
    private func runImport() {
        guard let result = session.runImport(into: context) else {
            path = []
            return
        }
        path.append(.done(result))
        Task { await session.requestReminderPermission(in: context) }
    }

    /// Ends the flow: hands control back to the caller if it asked, otherwise closes the sheet.
    private func finish() {
        if let onFinish { onFinish() } else { dismiss() }
    }
}

/// Background and padding shared by every import screen.
private extension View {
    func screenStyle() -> some View {
        self.mainContainerStyling()
            .background(Color.screenBackground.ignoresSafeArea())
    }
}

#Preview {
    ImportFlowView()
}
