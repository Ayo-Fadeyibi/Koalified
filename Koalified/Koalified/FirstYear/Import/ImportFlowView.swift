//
//  ImportFlowView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 31/10/2026.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Runs the timetable import: pick a .ics file, choose which semesters to import, show the result.
/// This view owns the state and the logic; each screen lives in its own file.
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

    @State private var path: [Route] = []
    @State private var showPicker = false
    @State private var parsedEvents: [ParsedEvent] = []
    @State private var semesters: [DetectedSemester] = []
    @State private var selected: Set<String> = []
    @State private var errorMessage: String?

    /// Semesters that have both a term and a year. Others wait for the "Other courses" update.
    private var importable: [DetectedSemester] {
        semesters.filter { $0.term != nil && $0.year != nil }
    }

    private var unplacedCount: Int {
        parsedEvents.filter { $0.term == nil || $0.year == nil }.count
    }

    var body: some View {
        NavigationStack(path: $path) {
            ImportTimetableView(
                errorMessage: errorMessage,
                isOnboarding: isOnboarding,
                onImportLink: { loadLink($0) },
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
            if case .success(let url) = picked { load(url) }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .chooseSemester:
            ChooseSemesterView(
                semesters: importable,
                unplacedCount: unplacedCount,
                selected: selected,
                statusFor: status(of:),
                onToggle: toggle,
                onImport: { path.append(.review) },
                onChooseDifferentFile: { showPicker = true }
            )
        case .review:
            // "Looks right" is what actually runs the import.
            FoundInTimetableView(courses: foundCourses(), onConfirm: runImport)
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

    // MARK: - Logic

    /// "Current", "Past" or "Upcoming", worked out from the class dates in that semester.
    /// A semester stays current through swotvac and exams, which come after the last class.
    private func status(of semester: DetectedSemester) -> String? {
        let inSemester = events(in: semester, from: parsedEvents)
        guard let first = inSemester.map({ $0.start }).min(),
              let lastClass = inSemester.map({ $0.end }).max() else { return nil }
        let examAllowance: TimeInterval = 35 * 24 * 60 * 60   // swotvac + exam period, about five weeks
        let last = lastClass.addingTimeInterval(examAllowance)
        let now = Date()
        if now > last { return "Past" }
        if now >= first { return "Current" }
        return "Upcoming"
    }

    /// The courses in the ticked semesters, with their class counts, for the review screen.
    private func foundCourses() -> [FoundCourse] {
        var found: [FoundCourse] = []
        for semester in importable where selected.contains(semester.id) {
            let inSemester = events(in: semester, from: parsedEvents)
            for (code, classes) in Dictionary(grouping: inSemester, by: { $0.courseCode }) {
                found.append(FoundCourse(code: code,
                                         title: classes.compactMap { $0.title }.first,
                                         classCount: classes.count))
            }
        }
        return found.sorted { $0.code < $1.code }
    }

    private func toggle(_ semester: DetectedSemester) {
        if selected.contains(semester.id) {
            selected.remove(semester.id)
        } else {
            selected.insert(semester.id)
        }
    }

    /// Reads the picked file, finds its semesters and moves to the right screen.
    private func load(_ url: URL) {
        errorMessage = nil
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Couldn't open that file."
            path = []
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            process(try String(contentsOf: url, encoding: .utf8))
        } catch {
            errorMessage = "Couldn't read that file."
            path = []
        }
    }

    /// Downloads the calendar from a pasted link and moves on like a picked file.
    /// The link is only used for this request: it is not stored or logged.
    private func loadLink(_ text: String) {
        errorMessage = nil
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Calendar apps hand out webcal:// links; they are plain https underneath.
        if trimmed.lowercased().hasPrefix("webcal://") {
            trimmed = "https://" + trimmed.dropFirst("webcal://".count)
        }
        guard let url = URL(string: trimmed), url.scheme?.lowercased() == "https" else {
            errorMessage = "That doesn't look like a timetable link."
            return
        }
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      let text = String(data: data, encoding: .utf8) else {
                    errorMessage = "Couldn't read a timetable from that link."
                    return
                }
                process(text)
            } catch {
                errorMessage = "Couldn't reach that link."
            }
        }
    }

    /// Parses calendar text, finds its semesters and moves to the right screen.
    private func process(_ text: String) {
        parsedEvents = parseICS(text)
        semesters = detectSemesters(from: parsedEvents)
        if importable.isEmpty {
            path = [.noClasses]
        } else {
            selected = Set(importable.prefix(1).map { $0.id })   // newest semester ticked by default
            path = [.chooseSemester]
        }
    }

    /// Ends the flow: hands control back to the caller if it asked, otherwise closes the sheet.
    private func finish() {
        if let onFinish { onFinish() } else { dismiss() }
    }

    /// Imports every ticked semester, then refreshes reminders and widgets.
    private func runImport() {
        var total = ImportResult()
        do {
            for semester in importable where selected.contains(semester.id) {
                let r = try importEvents(events(in: semester, from: parsedEvents), into: context)
                total.added += r.added
                total.updated += r.updated
                total.unchanged += r.unchanged
            }
            total.skipped = unplacedCount
            AppSync.dataChanged(in: context)
            path.append(.done(total))
        } catch {
            errorMessage = "Something went wrong while importing."
            path = []
        }
    }
}

/// Background and padding shared by every import screen.
private extension View {
    func screenStyle() -> some View {
        self.mainContainerStyling()
            .background(Color.canvas.ignoresSafeArea())
    }
}

#Preview {
    ImportFlowView()
}
