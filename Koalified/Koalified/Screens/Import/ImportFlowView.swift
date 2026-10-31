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

    /// The screens that can be pushed on top of the start screen.
    private enum Route: Hashable { case chooseSemester, noClasses, done(ImportResult) }

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
            StartImportView(errorMessage: errorMessage) { showPicker = true }
                .screenStyle()
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
                onImport: runImport,
                onChooseDifferentFile: { showPicker = true }
            )
        case .noClasses:
            NoClassesFoundView(
                onChooseDifferentFile: { showPicker = true },
                onAddManually: { dismiss() }
            )
        case .done(let result):
            ImportDoneView(result: result) { dismiss() }
                .navigationBarBackButtonHidden(true)   // importing again from here would be confusing
        }
    }

    // MARK: - Logic

    /// "Current", "Past" or "Upcoming", worked out from the class dates in that semester.
    private func status(of semester: DetectedSemester) -> String? {
        let inSemester = events(in: semester, from: parsedEvents)
        guard let first = inSemester.map({ $0.start }).min(),
              let last = inSemester.map({ $0.end }).max() else { return nil }
        let now = Date()
        if now > last { return "Past" }
        if now >= first { return "Current" }
        return "Upcoming"
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
            let text = try String(contentsOf: url, encoding: .utf8)
            parsedEvents = parseICS(text)
            semesters = detectSemesters(from: parsedEvents)
            if importable.isEmpty {
                path = [.noClasses]
            } else {
                selected = Set(importable.prefix(1).map { $0.id })   // newest semester ticked by default
                path = [.chooseSemester]
            }
        } catch {
            errorMessage = "Couldn't read that file."
            path = []
        }
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
