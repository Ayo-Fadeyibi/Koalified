//
//  AssessmentsContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 25/10/2026.
//

import SwiftUI
import SwiftData

struct AssessmentsContentView: View {
    let course: Course
    
    let onAdd: () -> Void

    private var marked: [AssessmentItem] {
        course.assessments.filter { $0.mark != nil }.sorted { $0.dueDate < $1.dueDate }
    }
    private var upcoming: [AssessmentItem] {
        course.assessments.filter { $0.mark == nil }.sorted { $0.dueDate < $1.dueDate }
    }

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
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.inkSecondary)
                    list(marked) { item in
                        Text("\(Int((item.mark ?? 0).rounded()))%")
                            .font(.headline)
                            .foregroundStyle(Color.inkPrimary)
                    }
                }

                if !upcoming.isEmpty {
                    Text("Upcoming · \(upcoming.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.inkSecondary)
                    list(upcoming) { _ in
                        Button { print("add mark") } label: {
                            Label("Add mark", systemImage: "plus")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.inkPop.opacity(0.12), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                SecondaryButton(title: "Add an assessment") { onAdd() }
                SecondaryButton(title: "Open what-if calculator") { print("calculator") }
            }

        }
        .background(Color.canvas)
    }

    private var summaryCard: some View {
        Card {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKED AVERAGE").font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.inkSecondary)
                    Text(course.markedAverage.map { "\(num($0))%" } ?? "–")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.inkPrimary)
                    Text("\(num(course.earnedPoints)) / \(num(course.markedWeight)) points earned")
                        .font(.caption).foregroundStyle(Color.inkSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text("ESTIMATED GRADE").font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.inkSecondary)
                    Text("–")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.inkPrimary)
                    Text("At your current average")
                        .font(.caption).foregroundStyle(Color.inkSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
        }
    }

    private func list<Trailing: View>(
        _ items: [AssessmentItem],
        @ViewBuilder trailing: @escaping (AssessmentItem) -> Trailing
    ) -> some View {
        Card {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    AssessmentRow(item: item) { trailing(item) }
                    if item !== items.last { Divider().padding(.horizontal, 14) }
                }
            }
        }
    }
}

struct AssessmentRow<Trailing: View>: View {
    let item: AssessmentItem
    let trailing: Trailing

    init(item: AssessmentItem, @ViewBuilder trailing: () -> Trailing) {
        self.item = item
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.inkPrimary)
                Text("\(Int(item.weight))% of course · due \(item.dueDate.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(.caption)
                    .foregroundStyle(Color.inkSecondary)
            }
            Spacer()
            trailing
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.inkSecondary)
        }
        .padding(14)
    }
}

