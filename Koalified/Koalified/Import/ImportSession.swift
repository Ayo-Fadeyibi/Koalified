//
//  ImportSession.swift
//  Koalified
//
//  The logic behind the import flow: loading a file or link, working out semesters and courses,
//  and running the import. `ImportFlowView` only shows screens and moves between them.
//

import Foundation
import Observation
import SwiftData

/// Which screen the flow should show after a file or link has been read.
enum ImportLoadOutcome {
    case chooseSemester
    case noClasses
    case failed          // `errorMessage` says why
}

/// Holds everything the import screens share: the parsed events, the semesters found,
/// which ones are ticked, and the latest error.
@MainActor
@Observable
final class ImportSession {
    private(set) var parsedEvents: [ParsedEvent] = []
    private(set) var semesters: [DetectedSemester] = []
    private(set) var selected: Set<String> = []
    var errorMessage: String?

    /// Semesters that have both a term and a year. Others wait for the "Other courses" update.
    var importable: [DetectedSemester] {
        semesters.filter { $0.term != nil && $0.year != nil }
    }

    /// Classes in the file with no term or year, which can't be imported yet.
    var unplacedCount: Int {
        parsedEvents.filter { $0.term == nil || $0.year == nil }.count
    }

    // MARK: - Loading

    /// Reads the picked file, finds its semesters and says which screen comes next.
    func load(_ url: URL) -> ImportLoadOutcome {
        errorMessage = nil
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Couldn't open that file."
            return .failed
        }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            return process(try String(contentsOf: url, encoding: .utf8))
        } catch {
            errorMessage = "Couldn't read that file."
            return .failed
        }
    }

    /// Downloads the calendar from a pasted link and says which screen comes next.
    /// The link is only used for this request: it is not stored or logged.
    func loadLink(_ text: String) async -> ImportLoadOutcome {
        errorMessage = nil
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Calendar apps hand out webcal:// links; they are plain https underneath.
        if trimmed.lowercased().hasPrefix("webcal://") {
            trimmed = "https://" + trimmed.dropFirst("webcal://".count)
        }
        guard let url = URL(string: trimmed), url.scheme?.lowercased() == "https" else {
            errorMessage = "That doesn't look like a timetable link."
            return .failed
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let text = String(data: data, encoding: .utf8) else {
                errorMessage = "Couldn't read a timetable from that link."
                return .failed
            }
            return process(text)
        } catch {
            errorMessage = "Couldn't reach that link."
            return .failed
        }
    }

    /// Parses calendar text and finds its semesters.
    private func process(_ text: String) -> ImportLoadOutcome {
        parsedEvents = parseICS(text)
        semesters = detectSemesters(from: parsedEvents)
        guard !importable.isEmpty else { return .noClasses }
        selected = Set(importable.prefix(1).map { $0.id })   // newest semester ticked by default
        return .chooseSemester
    }

    // MARK: - Choosing semesters

    func toggle(_ semester: DetectedSemester) {
        if selected.contains(semester.id) {
            selected.remove(semester.id)
        } else {
            selected.insert(semester.id)
        }
    }

    /// "Current", "Past" or "Upcoming", worked out from the class dates in that semester.
    /// A semester stays current through swotvac and exams, which come after the last class.
    func status(of semester: DetectedSemester) -> String? {
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
    func foundCourses() -> [FoundCourse] {
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

    // MARK: - Importing

    /// Imports every ticked semester, then refreshes reminders and widgets.
    /// On failure it sets `errorMessage` and returns nil.
    func runImport(into context: ModelContext) -> ImportResult? {
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
            return total
        } catch {
            errorMessage = "Something went wrong while importing."
            return nil
        }
    }

    /// Asks about reminders right after an import. If they say yes, rebuilds the reminders
    /// now that iOS will deliver them.
    func requestReminderPermission(in context: ModelContext) async {
        if await NotificationScheduler.requestPermissionIfNeeded() {
            AppSync.dataChanged(in: context)
        }
    }
}
