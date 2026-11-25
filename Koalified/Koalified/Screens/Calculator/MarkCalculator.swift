import Foundation

// MARK: - Models

struct GradeCutoff: Equatable {
    let grade: Int
    let cutoff: Double
}

/// Where a course stands for one grade.
struct GradeDetailsRow: Identifiable, Equatable {
    var id: Int { grade }
    let grade: Int
    /// Average needed on the unmarked assessments to reach this grade (0 once it's achieved).
    let requiredPercent: Double
    let achieved: Bool
    /// Already achieved, or still reachable with the weight that's left.
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

    /// Weighted score so far (out of 100) and the fraction of weight completed (0...1).
    /// Only assessments with a mark count; marks are capped to 0–100.
    static func calculateTotalScore(_ items: [AssessmentItem]) -> (score: Double, totalWeight: Double) {
        var weightedSum = 0.0
        var totalWeight = 0.0
        for item in items {
            guard let mark = item.mark else { continue }
            let weight = item.weight / 100
            weightedSum += max(min(mark, 100), 0) * weight
            totalWeight += weight
        }
        return (round2(weightedSum), totalWeight)
    }

    /// Percent of the final grade that hasn't been marked yet.
    static func remainingWeight(_ items: [AssessmentItem]) -> Int {
        let (_, totalWeight) = calculateTotalScore(items)
        return Int((max(1 - totalWeight, 0) * 100).rounded())
    }

    /// One row per grade: required mark, whether already achieved, whether still reachable.
    static func gradeDetailsRows(items: [AssessmentItem],
                                 cutoffs: [GradeCutoff] = uqGradeCutoffs) -> [GradeDetailsRow] {
        let (score, totalWeight) = calculateTotalScore(items)
        let remaining = max(1 - totalWeight, 0)

        return cutoffs.map { info in
            let increase = info.cutoff - score
            let requiredPercent = remaining > 0 ? max(increase, 0) / remaining : 0
            let achieved = score >= info.cutoff
            let obtainable = achieved || (remaining > 0 && increase <= remaining * 100)

            return GradeDetailsRow(
                grade: info.grade,
                requiredPercent: max(round2(requiredPercent), 0),
                achieved: achieved,
                obtainable: obtainable
            )
        }
    }
}
