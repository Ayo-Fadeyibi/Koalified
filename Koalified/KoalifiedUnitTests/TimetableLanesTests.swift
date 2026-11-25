//
//  TimetableLanesTests.swift
//  KoalifiedUnitTests
//

import Foundation
import Testing
@testable import Koalified

/// How `TimetableWeek.lanes(for:)` groups overlapping classes and places them side by side.
struct TimetableLanesTests {
    private let base = Date(timeIntervalSinceReferenceDate: 0)

    /// An interval from `start` to `end`, in hours after `base`.
    private func hours(_ start: Double, _ end: Double) -> DateInterval {
        DateInterval(start: base.addingTimeInterval(start * 3600), end: base.addingTimeInterval(end * 3600))
    }

    @Test func separateClassesEachGetTheirOwnSingleLaneCluster() {
        let placements = TimetableWeek.lanes(for: [hours(9, 10), hours(11, 12)])
        #expect(placements.map(\.laneCount) == [1, 1])
        #expect(placements[0].cluster != placements[1].cluster)
    }

    @Test func backToBackClassesDoNotClash() {
        let placements = TimetableWeek.lanes(for: [hours(9, 10), hours(10, 11)])
        #expect(placements.map(\.laneCount) == [1, 1])
    }

    @Test func identicalClassesSitSideBySide() {
        let placements = TimetableWeek.lanes(for: [hours(9, 11), hours(9, 11)])
        #expect(placements.map(\.lane).sorted() == [0, 1])
        #expect(placements.map(\.laneCount) == [2, 2])
        #expect(placements[0].cluster == placements[1].cluster)
    }

    @Test func freedLaneIsReusedInsideACluster() {
        // A 9–11 and C 11–12 never overlap, so they share a lane beside B 10–12.
        let placements = TimetableWeek.lanes(for: [hours(9, 11), hours(10, 12), hours(11, 12)])
        #expect(placements.map(\.lane) == [0, 1, 0])
        #expect(placements.allSatisfy { $0.laneCount == 2 })
    }

    @Test func resultsKeepTheInputOrder() {
        let placements = TimetableWeek.lanes(for: [hours(10, 12), hours(9, 11)])
        // The earlier class takes the first lane even though it was given second.
        #expect(placements.map(\.lane) == [1, 0])
    }

    @Test func longerClassTakesTheFirstLaneWhenStartsMatch() {
        let placements = TimetableWeek.lanes(for: [hours(9, 10), hours(9, 12)])
        #expect(placements.map(\.lane) == [1, 0])
    }

    @Test func threeWayClashNeedsThreeLanes() {
        let placements = TimetableWeek.lanes(for: [hours(9, 11), hours(9, 10), hours(9.5, 10.5)])
        #expect(placements.map(\.lane).sorted() == [0, 1, 2])
        #expect(placements.allSatisfy { $0.laneCount == 3 })
    }

    @Test func noClassesGiveNoPlacements() {
        #expect(TimetableWeek.lanes(for: []).isEmpty)
    }

    // MARK: - Clash limit

    private func times(_ start: Double, _ end: Double) -> (start: Date, end: Date) {
        let interval = hours(start, end)
        return (interval.start, interval.end)
    }

    private func classes(_ ranges: [(start: Date, end: Date)]) -> [ClassSession] {
        ranges.map { ClassSession(start: $0.start, end: $0.end, type: .LEC) }
    }

    @Test func twoOverlappingClassesLeaveRoomForAThird() {
        let existing = classes([times(9, 11), times(9, 10)])
        #expect(!exceedsClashLimit(existing: existing, newTimes: [times(9, 10)]))
    }

    @Test func threeOverlappingClassesBlockAFourth() {
        let existing = classes([times(9, 11), times(9, 10), times(9.5, 10.5)])
        #expect(exceedsClashLimit(existing: existing, newTimes: [times(9.5, 10)]))
    }

    @Test func classesOutsideTheNewTimeDoNotCount() {
        let existing = classes([times(7, 8), times(8, 9), times(11, 12)])
        #expect(!exceedsClashLimit(existing: existing, newTimes: [times(9, 11)]))
    }

    @Test func weeklyClassIsCheckedOneWeekAtATime() {
        // One clash in each of three weeks is never more than two classes on at once.
        let week = 7 * 24.0
        let existing = classes([times(9, 10), times(9 + week, 10 + week), times(9 + 2 * week, 10 + 2 * week)])
        let newTimes = [times(9, 10), times(9 + week, 10 + week), times(9 + 2 * week, 10 + 2 * week)]
        #expect(!exceedsClashLimit(existing: existing, newTimes: newTimes))
    }
}
