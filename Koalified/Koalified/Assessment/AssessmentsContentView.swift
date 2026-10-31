//
//  AssessmentsContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

/// The body of the course detail screen when the course has assessments: a summary card,
/// the marked and upcoming assessment lists, and buttons to add an assessment or open the calculator.
struct AssessmentsContentView: View {
    let course: Course
    
    /// Called when the user taps "Add an assessment".
    let onAdd: () -> Void
    
    /// Assessments that already have a mark, earliest due date first.
    private var marked: [AssessmentItem] {
        course.assessments.filter { $0.mark != nil }.sorted { $0.dueDate < $1.dueDate }
    }
    /// Assessments still waiting for a mark, earliest due date first.
    private var upcoming: [AssessmentItem] {
        course.assessments.filter { $0.mark == nil }.sorted { $0.dueDate < $1.dueDate }
    }
    
    /// Formats a number with at most one decimal place (e.g. 12.5, 20).
    private func num(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                summaryCard
                    .padding(.bottom, 20)
                
                if !marked.isEmpty {
                    Text("Marked · \(marked.count)")
                        .font(.fredoka(.subheadline, .semibold))
                        .foregroundStyle(Color.inkSecondary)
                    AssessmentList(marked) { item in
                        Text("\(Int((item.mark ?? 0).rounded()))%")
                            .font(.fredoka(.headline))
                            .foregroundStyle(Color.inkPrimary)
                    }
                }
                
                if !upcoming.isEmpty {
                    Text("Upcoming · \(upcoming.count)")
                        .font(.fredoka(.subheadline, .semibold))
                        .foregroundStyle(Color.inkSecondary)
                    AssessmentList(upcoming) { _ in
                        Button { print("add mark") } label: {
                            Label("Add mark", systemImage: "plus")
                                .font(.fredoka(.caption, .semibold))
                                .foregroundStyle(Color.accentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .neoBrutalist(backgroundColor: Color.surface, cornerRadius: 20, shadowOffset: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                
                PrimaryButton(title: "Add an assessment") { onAdd() }
                SecondaryButton(title: "Open what-if calculator") { print("calculator") }
            }
            
        }
        .background(Color.canvas)
    }
    
    /// Two-column card: the weighted average of marked work and points earned (left),
    /// and an estimated grade (right; not calculated yet, shows a dash).
    private var summaryCard: some View {
        Card {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKED AVERAGE").font(.fredoka(.caption2, .semibold))
                        .foregroundStyle(Color.inkSecondary)
                    Text(course.markedAverage.map { "\(num($0))%" } ?? "–")
                        .font(.fredoka(.title, .bold))
                        .foregroundStyle(Color.inkPrimary)
                    Text("\(num(course.earnedPoints)) / \(num(course.markedWeight)) points earned")
                        .font(.fredoka(.caption)).foregroundStyle(Color.inkSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider().frame(height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ESTIMATED GRADE").font(.fredoka(.caption2, .semibold))
                        .foregroundStyle(Color.inkSecondary)
                    Text("–")
                        .font(.fredoka(.title, .bold))
                        .foregroundStyle(Color.inkPrimary)
                    Text("At your current average")
                        .font(.fredoka(.caption)).foregroundStyle(Color.inkSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
    }
}
   
