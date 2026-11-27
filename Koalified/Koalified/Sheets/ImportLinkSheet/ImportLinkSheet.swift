//
//  ImportLinkSheet.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/11/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportLinkSheet: View {
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
    @State private var showError = false
    /// True while a pasted link is being downloaded.
    @State private var isLoadingLink = false

    var body: some View {
        NavigationStack(path: $path) {
            ImportTimetableView(
                isOnboarding: isOnboarding,
                onImportLink: { link in
                    Task {
                        isLoadingLink = true
                        let outcome = await session.loadLink(link)
                        isLoadingLink = false
                        show(outcome)
                    }
                },
                onChooseFile: { showPicker = true },
                onSkip: isOnboarding ? { finish() } : nil
            )
            .screenStyle()
            .toolbar {
                if let onBack {
                    OnboardingBackButton(action: onBack)
                }

                if isOnboarding {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            finish()
                        } label: {
                            Text("Skip")
                                .font(.fredoka(.caption, .bold))
                                .foregroundStyle(Color.accent)
                                .padding()
                               
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
                    .screenStyle()
            }
        }
        .tint(Color.accent)
        .loadingOverlay(isPresented: isLoadingLink, message: "Fetching your timetable…")
        .overlay {
            // Pushed screens get an opaque background from the NavigationStack, which hides the border
            // `sheetBorder` draws behind the content. Drawing it on top keeps it visible on every screen,
            // and it stays still while screens slide underneath.
            if !isOnboarding {
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(Color.inkBorder, lineWidth: 3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .PopUp(isPresented: $showError,
               message: session.errorMessage ?? "Something went wrong.",
               image: "circle-x", colour: Color.redFill, feedback: .error)
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
        case .failed:
            path = []
            showError = true
        }
    }

    /// Runs the import, then shows the result and asks about reminders.
    private func runImport() {
        guard let result = session.runImport(into: context) else {
            path = []
            showError = true
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

/// Layout and navigation bar style shared by every import screen. The root and pushed screens use the
/// same bar settings, so the bar doesn't change height or background mid-push (that made the back
/// button animate in awkwardly). The border is drawn over the whole stack in `ImportLinkSheet.body`.
private extension View {
    func screenStyle() -> some View {
        self.padding(.horizontal, Layout.screenPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.screenBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}
#Preview {
    ImportLinkSheet()
}
