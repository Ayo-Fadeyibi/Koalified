import Foundation

// MARK: - Models

/// One assessment as typed text (weight and score are strings like "30%" and "17/20").
/// Named `MarkInput` so it doesn't clash with the SwiftData `AssessmentItem` model.
struct MarkInput: Identifiable, Codable, Equatable {
    var id: Int
    var assessment: String
    var weight: String      // e.g. "30%" or "30"
    var score: String       // e.g. "85%", "17/20", "85"
    var enabled: Bool = true
}

struct GradeCutoff: Equatable {
    let grade: Int
    let cutoff: Double
}

struct TargetSummary: Equatable {
    let requiredPercent: Double
    let requiredScore: String
    let remainingWeight: Int
}

struct GradeDetailsRow: Identifiable, Equatable {
    var id: Int { grade }
    let grade: Int
    let cutoff: Double
    let requiredPercent: Double
    let requiredScore: String
    let achieved: Bool
    let obtainable: Bool
}

// UQ grade cutoffs (same values as the web app)
let uqGradeCutoffs: [GradeCutoff] = [
    .init(grade: 1, cutoff: 0),
    .init(grade: 2, cutoff: 30),
    .init(grade: 3, cutoff: 45),
    .init(grade: 4, cutoff: 50),
    .init(grade: 5, cutoff: 65),
    .init(grade: 6, cutoff: 75),
    .init(grade: 7, cutoff: 85),
]

// MARK: - Calculator

enum MarkCalculator {

    private static func round2(_ v: Double) -> Double { (v * 100).rounded() / 100 }

    /// 33.0 -> "33", 33.5 -> "33.5", 0 -> "0".
    private static func fmt(_ v: Double) -> String {
        round2(v).formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
    }

    private static func matches(_ s: String, _ pattern: String) -> Bool {
        s.range(of: "^" + pattern + "$", options: .regularExpression) != nil
    }

    private static let num = #"\d+(?:\.\d+)?"#
    private static let ws = #"\s*"#

    /// "85%", "17/20" or "85" -> percentage (0...100+), nil if unparseable.
    static func parseScore(_ value: String) -> Double? {
        let v = value.trimmingCharacters(in: .whitespaces)
        if v.isEmpty { return nil }

        if matches(v, "\(num)\(ws)%") {
            return Double(v.dropLast().trimmingCharacters(in: .whitespaces))
        }

        if matches(v, "\(num)\(ws)/\(ws)\(num)") {
            let parts = v.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces) }
            if let n = Double(parts[0]), let d = Double(parts[1]), d != 0 { return n / d * 100 }
            return nil
        }

        if matches(v, num) { return Double(v) }
        return nil
    }

    /// "30%", "30 %" or "30" -> 30
    static func parseWeight(_ value: String) -> Double? {
        let v = value.trimmingCharacters(in: .whitespaces)
        if matches(v, "\(num)\(ws)%") { return Double(v.dropLast().trimmingCharacters(in: .whitespaces)) }
        return matches(v, num) ? Double(v) : nil
    }

    /// Weighted score so far (out of 100) and the fraction of weight completed (0...1).
    static func calculateTotalScore(_ items: [MarkInput]) -> (score: Double, totalWeight: Double) {
        var weightedSum = 0.0
        var totalWeight = 0.0
        for item in items where item.enabled {
            guard let score = parseScore(item.score),
                  let w = parseWeight(item.weight) else { continue }
            let weight = w / 100
            let capped = max(min(score, 100), 0)
            weightedSum += capped * weight
            totalWeight += weight
        }
        return (round2(weightedSum), totalWeight)
    }

    static func enabledWeight(_ items: [MarkInput]) -> Double {
        items.filter(\.enabled).reduce(0) { $0 + (parseWeight($1.weight) ?? 0) }
    }

    static func isWeightValid(_ items: [MarkInput]) -> Bool {
        Int(enabledWeight(items).rounded()) == 100
    }

    static func clampPercent(_ v: Double) -> Double {
        v.isNaN ? 0 : max(0, min(100, round2(v)))
    }

    /// Best possible final mark: current score + all remaining weight at 100%.
    static func maxPossibleScore(_ items: [MarkInput]) -> Double {
        let (score, totalWeight) = calculateTotalScore(items)
        return clampPercent(score + max(1 - totalWeight, 0) * 100)
    }

    /// What you need on the remaining assessment to reach `targetGrade`.
    static func targetSummary(items: [MarkInput],
                              targetGrade: Int,
                              cutoffs: [GradeCutoff] = uqGradeCutoffs) -> TargetSummary {
        let (score, totalWeight) = calculateTotalScore(items)
        let info = cutoffs.first { $0.grade == targetGrade } ?? cutoffs[0]
        let remaining = max(1 - totalWeight, 0)
        let increase = max(info.cutoff - score, 0)
        let requiredPercent = remaining > 0 ? increase / remaining : 0

        return TargetSummary(
            requiredPercent: max(round2(requiredPercent), 0),
            requiredScore: "\(fmt(increase))/\(Int((remaining * 100).rounded()))",
            remainingWeight: Int((remaining * 100).rounded())
        )
    }

    /// One row per grade: required mark, whether already achieved, whether still reachable.
    static func gradeDetailsRows(items: [MarkInput],
                                 cutoffs: [GradeCutoff] = uqGradeCutoffs) -> [GradeDetailsRow] {
        let (score, totalWeight) = calculateTotalScore(items)
        let remaining = max(1 - totalWeight, 0)

        return cutoffs.map { info in
            let increase = info.cutoff - score
            let capped = max(increase, 0)
            let requiredPercent = remaining > 0 ? capped / remaining : 0
            let achieved = score >= info.cutoff
            let obtainable = achieved || (remaining > 0 && increase <= remaining * 100)

            return GradeDetailsRow(
                grade: info.grade,
                cutoff: info.cutoff,
                requiredPercent: max(round2(requiredPercent), 0),
                requiredScore: "\(fmt(capped))/\(Int((remaining * 100).rounded()))",
                achieved: achieved,
                obtainable: obtainable
            )
        }
    }
}

// MARK: - Course bridge

extension Course {
    /// This course's assessments as calculator input, oldest due date first. Unmarked ones have an empty score.
    var markInputs: [MarkInput] {
        assessments
            .sorted { $0.dueDate < $1.dueDate }
            .enumerated()
            .map { index, item in
                MarkInput(id: index,
                          assessment: item.title,
                          weight: "\(item.weight.formatted(.number.precision(.fractionLength(0...2))))%",
                          score: item.mark.map { "\($0.formatted(.number.precision(.fractionLength(0...2))))%" } ?? "")
            }
    }
}

// MARK: - Example
//
// let items = [
//     MarkInput(id: 1, assessment: "Quiz",   weight: "20%", score: "17/20"),
//     MarkInput(id: 2, assessment: "Assign", weight: "30%", score: "70%"),
//     MarkInput(id: 3, assessment: "Exam",   weight: "50%", score: ""),
// ]
// MarkCalculator.calculateTotalScore(items)             // (score: 38.0, totalWeight: 0.5)
// MarkCalculator.targetSummary(items: items, targetGrade: 7)
