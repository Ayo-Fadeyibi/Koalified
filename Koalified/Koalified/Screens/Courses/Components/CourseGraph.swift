//
//  CourseGraph.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/11/2026.
//

import SwiftUI
import SwiftData
import Charts

struct ChartPoint: Identifiable {
    let index: Int
    let label: String
    let value: Double
    let isMarked: Bool
    var id: Int { index }   // also fixes the UUID flicker
}



struct CourseGraph: View {
    
    let course: Course

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Flips to true the first time the card scrolls into view, which kicks off the entrance animation.
    @State private var hasAppeared = false

    private var sortedAssessments: [AssessmentItem] {
        
        let assessments = course.assessments
        
        return assessments.sorted {
            $0.dueDate < $1.dueDate
        }
        
    }
    
    private var hasMarks: Bool {
        course.assessments.contains { $0.mark != nil }
    }

    
    /// Running weighted average: updates the accumulated mark×weight and weight totals in place.
    private func assessmentValue (previousMarkWeight: inout Double, currentMark: Double, previousWeight: inout Double, currentWeight: Double) -> Double {
        
        let totalWeight = previousWeight + currentWeight
        guard totalWeight > 0 else { return 0 }
        
        let value = (previousMarkWeight + (currentMark * currentWeight)) / (previousWeight + currentWeight)

        previousMarkWeight = previousMarkWeight + (currentMark * currentWeight)
        previousWeight = previousWeight + currentWeight
        
        return value
    }


    private var chartPoints: [ChartPoint] {
    
        var markWeight = 0.0
        var weight = 0.0
        
        return sortedAssessments.enumerated().map {index, assessment -> ChartPoint in

            if let assessmentMark = assessment.mark {
                let value = assessmentValue(previousMarkWeight: &markWeight, currentMark: assessmentMark, previousWeight: &weight, currentWeight: assessment.weight)
                return ChartPoint(index: index, label: assessment.title, value: value, isMarked: true)
            }

            // Not marked yet: project the current running average forward.
            let projected = weight > 0 ? markWeight / weight : 0
            return ChartPoint(index: index, label: assessment.title, value: projected, isMarked: false)
        }
    }
    
    private static let passMark = 50.0

    /// Where the course ends up if every unmarked assessment matches the current average.
    private var projectedFinal: Double {
        chartPoints.last?.value ?? 0
    }

    private var projectedGrade: Int {
        // Use the same rounded percent the headline shows, so "about 45%" never reads as Grade 2.
        let shown = projectedFinal.rounded()
        return uqGradeCutoffs.last { shown >= $0.cutoff }?.grade ?? 1
    }

    /// Red for a fail, amber for a bare pass, ink for a 5, green for a 6 or 7.
    private var gradeColor: Color {
        switch projectedGrade {
        case ...3: Color.errorText
        case 4: Color.courseAmber
        case 5: Color.textPrimary
        default: Color.greenDeep
        }
    }

    private var markedCount: Int {
        chartPoints.filter(\.isMarked).count
    }

    /// Bottom of the y-axis: the pass line, unless a point falls below it.
    private var yLowerBound: Double {
        let lowest = chartPoints.map(\.value).min() ?? Self.passMark
        return min(Self.passMark, (lowest / 10).rounded(.down) * 10)
    }

    /// Before the entrance animation, every point sits on the bottom of the chart; it then springs up to its value.
    private func plotted(_ p: ChartPoint) -> Double {
        hasAppeared ? p.value : yLowerBound
    }

    private var entranceAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.7, dampingFraction: 0.75)
    }

    /// Used when a mark is added or edited, so the line glides to its new shape.
    private var updateAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.4)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Projected grade")
                .font(.fredoka(.title3, .bold))
                .foregroundStyle(Color.textPrimary)

            if hasMarks {
                PlainCard {
                    Text("If you keep this pace")
                        .font(.system(.subheadline, design: .monospaced).weight(.medium))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textPrimary)

                    // The percentage counts up from the chart floor on entrance and rolls when marks change.
                    let shownPercent = Int((hasAppeared ? projectedFinal : yLowerBound).rounded())
                    Text("\(Text("Grade \(projectedGrade)").foregroundStyle(gradeColor)) · about \(shownPercent)%")
                        .font(.fredoka(.title, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .contentTransition(.numericText(value: Double(shownPercent)))
                        .animation(updateAnimation, value: projectedGrade)

                    chart

                    Text("\(markedCount) of \(chartPoints.count) assessments marked. Solid line is your results so far; dashed line assumes you keep your current average.")
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                PlainCard {
                    Text("No marks yet. Add a mark to see your projected grade.")
                        .font(.fredoka(.subheadline))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        // Run the entrance once, when at least half the card is on screen.
        .onScrollVisibilityChange(threshold: 0.5) { isVisible in
            guard isVisible, !hasAppeared else { return }
            withAnimation(entranceAnimation) { hasAppeared = true }
        }
        // Marks added or edited elsewhere: animate the chart into its new shape.
        .animation(updateAnimation, value: chartPoints.map(\.value))
    }

    private var chart: some View {
        let marked = chartPoints.filter(\.isMarked)
        let projected = chartPoints.filter { !$0.isMarked }
        // The dashed line starts from the last real mark so the two lines join up.
        let dashed = (marked.last.map { [$0] } ?? []) + projected
        let finalIndex = chartPoints.last?.index

        return Chart {
            RuleMark(y: .value("Pass", Self.passMark))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                .foregroundStyle(Color.textSecondary.opacity(0.6))

            ForEach(marked) { p in
                LineMark(x: .value("Assessment", Double(p.index)), y: .value("Percent", plotted(p)),
                         series: .value("Type", "Marked"))
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Color.inkBorder)
            }

            if projected.isEmpty == false {
                ForEach(dashed) { p in
                    LineMark(x: .value("Assessment", Double(p.index)), y: .value("Percent", plotted(p)),
                             series: .value("Type", "Projected"))
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6]))
                        .foregroundStyle(Color.inkBorder)
                }
            }

            ForEach(chartPoints) { p in
                let isFinal = p.index == finalIndex
                PointMark(x: .value("Assessment", Double(p.index)), y: .value("Percent", plotted(p)))
                    .symbol {
                        pointSymbol(isMarked: p.isMarked, isFinal: isFinal)
                    }
                    .annotation(position: .top, alignment: .trailing, spacing: 10) {
                        if isFinal {
                            Text("≈ \(Int(p.value.rounded()))%")
                                .font(.system(.footnote, design: .monospaced).weight(.bold))
                                .foregroundStyle(Color.textPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.tintAmber, in: Capsule())
                                .overlay(Capsule().strokeBorder(Color.inkBorder, lineWidth: 2))
                                .contentTransition(.numericText(value: p.value))
                                // Pops in once the line has risen, rather than riding up with it.
                                .opacity(hasAppeared ? 1 : 0)
                                .scaleEffect(hasAppeared || reduceMotion ? 1 : 0.6, anchor: .bottomTrailing)
                                .animation(entranceAnimation.delay(reduceMotion ? 0 : 0.45), value: hasAppeared)
                        }
                    }
            }
        }
        .chartYScale(domain: yLowerBound...100)
        // Padding keeps the first and last dots (and their labels) from being clipped.
        .chartXScale(domain: -0.4...(Double(max(chartPoints.count - 1, 1)) + 0.4))
        .chartYAxis {
            AxisMarks(position: .leading, values: [75, 100]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1.5))
                    .foregroundStyle(Color.textSecondary.opacity(0.25))
                AxisValueLabel()
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
            AxisMarks(position: .leading, values: [Self.passMark]) { _ in
                AxisValueLabel {
                    Text("PASS")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        // Built-in x-axis labels won't centre under their points, so they're drawn in the overlay instead.
        .chartXAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                if let plotAnchor = proxy.plotFrame {
                    let plot = geo[plotAnchor]
                    ForEach(chartPoints) { p in
                        if let x = proxy.position(forX: Double(p.index)) {
                            Text(p.label)
                                .font(.system(.footnote, design: .monospaced).weight(.bold))
                                .foregroundStyle(Color.textPrimary)
                                // Long titles wrap within their own column instead of overlapping neighbours.
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 76, height: 36, alignment: .top)
                                .position(x: plot.minX + x, y: plot.maxY + 26)
                        }
                    }
                }
            }
        }
        .frame(height: 180)
        // Room below the plot for the overlay's labels.
        .padding(.bottom, 44)
        .padding(.top, 8)
    }

    /// Solid ink dot for marks, hollow dot for projections, larger mint dot for the final projection.
    @ViewBuilder
    private func pointSymbol(isMarked: Bool, isFinal: Bool) -> some View {
        if isFinal {
            Circle()
                .fill(Color.brandMint)
                .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 3))
                .frame(width: 22, height: 22)
        } else if isMarked {
            Circle()
                .fill(Color.inkBorder)
                .frame(width: 16, height: 16)
        } else {
            Circle()
                .fill(Color.cardSurface)
                .overlay(Circle().strokeBorder(Color.inkBorder, lineWidth: 3))
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
let course = try! PreviewData.container.mainContext
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "CSSE1001" }))
        .first!

    CourseGraph(course: course)
        .modelContainer(PreviewData.container)
        .mainContainerStyling()
}

/// Builds a one-off course from (title, weight, mark) entries, due a week apart, for previewing edge cases.
@MainActor
private func previewGraph(_ entries: [(String, Double, Double?)]) -> some View {
    let container = try! ModelContainer(
        for: Course.self, ClassSession.self, AssessmentItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let course = Course(courseCode: "MATH1051", title: "Calculus & Linear Algebra I",
                        term: .S2, year: 2026, color: .blue)
    container.mainContext.insert(course)

    for (offset, entry) in entries.enumerated() {
        let item = AssessmentItem(title: entry.0, weight: entry.1,
                                  dueDate: Date.now.addingTimeInterval(Double(offset) * 86_400 * 7),
                                  mark: entry.2, course: course)
        container.mainContext.insert(item)
    }

    return CourseGraph(course: course)
        .modelContainer(container)
        .mainContainerStyling()
}

#Preview("Failing") {
    previewGraph([
        ("Quiz 1", 10, 42), ("Assignment 1", 15, 35), ("Quiz 2", 10, 38),
        ("Assignment 2", 25, nil), ("Final exam", 40, nil),
    ])
}

#Preview("Mixed") {
    previewGraph([
        ("Quiz 1", 10, 85), ("Assignment 1", 25, 30), ("Quiz 2", 10, 70),
        ("Assignment 2", 15, 25), ("Final exam", 40, nil),
    ])
}

#Preview("Empty") {
    previewGraph([])
}
