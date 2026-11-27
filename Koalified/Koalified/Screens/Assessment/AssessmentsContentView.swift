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
    @Environment(\.modelContext) private var modelContext
    
    @State private var showConfirmation = false
    
    let course: Course
    
    /// Called when the user taps "Add an assessment".
    let onAdd: () -> Void

    /// Called when the user taps "Add mark" on an upcoming assessment.
    let onAddMark: (AssessmentItem) -> Void

    /// Assessments that already have a mark, earliest due date first.
    private var marked: [AssessmentItem] {
        course.assessments.filter { $0.mark != nil }.sorted { $0.dueDate < $1.dueDate }
    }
    /// Assessments still waiting for a mark, earliest due date first.
    private var upcoming: [AssessmentItem] {
        course.assessments.filter { $0.mark == nil }.sorted { $0.dueDate < $1.dueDate }
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openAssessment: Bool

    /// - Parameter startsOpen: Whether the card begins expanded (handy for previews).
    init(course: Course, startsOpen: Bool = true, onAdd: @escaping () -> Void,
         onAddMark: @escaping (AssessmentItem) -> Void = { _ in }) {
        self.course = course
        self.onAdd = onAdd
        self.onAddMark = onAddMark
        _openAssessment = State(initialValue: startsOpen)
    }

    private var toggleAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.35)
    }

    var body: some View {
        PlainCard {
            // The whole header row is the tap target, not just the chevron.
            Button {
                withAnimation(toggleAnimation) { openAssessment.toggle() }
            } label: {
                HStack {
                    Text("Assessments")
                        .font(.fredoka(.title3, .bold))
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    // Points down when closed ("tap to open") and turns to point up when open.
                    Image(systemName: "chevron.down")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.textPrimary)
                        .rotationEffect(.degrees(openAssessment ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(openAssessment ? Text("Expanded") : Text("Collapsed"))
            .accessibilityHint(openAssessment ? Text("Hides your assessments") : Text("Shows your assessments"))

            if openAssessment {
                // No inner ScrollView: the course screen already scrolls, so the card just grows to fit.
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    if marked.isEmpty && upcoming.isEmpty {
                        Text("No assessments yet.")
                            .font(.fredoka(.subheadline))
                            .foregroundStyle(Color.textSecondary)
                    }

                    if !marked.isEmpty {
                        section("Marked · \(marked.count)") {
                            AssessmentList(marked) { item in
                                
                                Text("\(Int((item.mark ?? 0).rounded()))%")
                                    .font(.fredoka(.headline))
                                    .foregroundStyle(Color.textPrimary)
                                HStack(spacing: 6) {
                                    Button { onAddMark(item) } label: {
                                    
                                            Image("square-pen")
                                                .font(.subheadline.weight(.bold))
                                                .foregroundStyle(Color.textPrimary)
                                       
                                    }
                                    .padding(.trailing, 10)
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(Text("Edit mark, \(Int((item.mark ?? 0).rounded())) percent"))
                                    
                                    //Spacer()
                                    
                                    Button {
                                                showConfirmation = true
                                    } label: {
                                        Image("trash")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                            .foregroundStyle(Color.redFill)
                                    }
                                            .confirmationDialog(
                                                "Are you sure you want to delete this?",
                                                isPresented: $showConfirmation,
                                                titleVisibility: .visible
                                            ) {
                                                Button("Delete", role: .destructive) {
                                                    // Perform delete action
                                                    modelContext.delete(item)
                                                    try? modelContext.save()
                                                    AppSync.dataChanged(in: modelContext)
                                                }
                                                Button("Cancel", role: .cancel) { }
                                            } message: {
                                                Text("This action cannot be undone.")
                                            }

                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }

                    if !upcoming.isEmpty {
                        section("Upcoming · \(upcoming.count)") {
                            AssessmentList(upcoming) { item in
                                PillButton(title: "Add mark", color: Color.accent,
                                           horizontalPadding: 12, verticalPadding: 7, shadowOffset: 2) { onAddMark(item) }
                            }
                        }
                    }

                    PrimaryButton(title: "Add an assessment") { onAdd() }
                }
                .padding(.top, 4)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        // Keeps the sliding content from drawing over the header or outside the card while it animates.
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusCard))
    }

    /// A small grey section title with its list underneath.
    private func section<Content: View>(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.fredoka(.subheadline, .semibold))
                .foregroundStyle(Color.textSecondary)
            content()
        }
    }
}

#Preview {
    let course = try! PreviewData.container.mainContext
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "CSSE1001" }))
        .first!

    AssessmentsContentView(course: course, onAdd: {})
        .modelContainer(PreviewData.container)
        .mainContainerStyling()
}

#Preview("Empty") {
    // A course with no assessments, in the empty container.
    let course = Course(courseCode: "COMP3506", title: "Algorithms & Data Structures",
                        term: .S2, year: 2026, color: .violet)
    EmptyPreviewData.container.mainContext.insert(course)

    return AssessmentsContentView(course: course, startsOpen: true, onAdd: {})
        .modelContainer(EmptyPreviewData.container)
        .mainContainerStyling()
}
   
