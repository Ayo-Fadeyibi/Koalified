//
//  ClassContentView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 24/11/2026.
//


import SwiftUI
import SwiftData

/// The body of the course detail screen when the course has assessments: a summary card,
/// the marked and upcoming assessment lists, and buttons to add an assessment or open the calculator.
struct ClassContentView: View {
    let course: Course
    
    private var classes: [ClassSession] {
        var seen = Set<String>()
        return course.sessions
            .sorted { $0.start < $1.start }
            .filter { session in
                let weekday = Calendar.current.component(.weekday, from: session.start)
                let key = "\(session.type)-\(weekday)-\(minutesIntoDay(session.start))-\(minutesIntoDay(session.end))"
                return seen.insert(key).inserted
            }
    }
    
    /// Called when the user taps "Add an assessment".
    let onAdd: () -> Void

    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var openAssessment: Bool

    /// - Parameter startsOpen: Whether the card begins expanded (handy for previews).
    init(course: Course, startsOpen: Bool = false, onAdd: @escaping () -> Void) {
        self.course = course
        self.onAdd = onAdd
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
                    Text("Classes")
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
            .accessibilityHint(openAssessment ? Text("Hides your clases") : Text("Shows your classes"))

            if openAssessment {
                // No inner ScrollView: the course screen already scrolls, so the card just grows to fit.
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    if classes.isEmpty {
                        Text("No Classes yet.")
                            .font(.fredoka(.subheadline))
                            .foregroundStyle(Color.textSecondary)
                    }

                    if !classes.isEmpty {
                        section("\(classes.count) Classes per week") {
                            ForEach(classes) { session in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 12) {
                                        Text(session.type.rawValue)
                                            .font(.fredoka(.body, .semibold))
                                            .foregroundStyle(Color.textPrimary)
                                            .frame(minWidth: 44)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 6)
                                            // Mint fill clipped to the same rounded shape as the border.
                                            .background(Color.tintMint, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                                    .strokeBorder(Color.inkBorder, lineWidth: 2)
                                            )

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(session.start, format: .dateTime.weekday(.abbreviated)) \(session.start, format: .dateTime.hour().minute())")
                                                .font(.fredoka(.subheadline, .bold))
                                                .foregroundStyle(Color.textPrimary)

                                            if let location = session.locationText {
                                                Text(location)
                                                    .secondaryTextStyling()
                                            }
                                        }

                                        Spacer(minLength: 0)
                                    }

                                    // Horizontal rule between rows, not after the last one.
                                    if session.id != classes.last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }


                    PrimaryButton(title: "Add a class") { onAdd() }
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

    ClassContentView(course: course, onAdd: {})
        .modelContainer(PreviewData.container)
        .mainContainerStyling()
}

#Preview("Empty") {
    // A course with no assessments, in the empty container.
    let course = Course(courseCode: "COMP3506", title: "Algorithms & Data Structures",
                        term: .S2, year: 2026, color: .violet)
    EmptyPreviewData.container.mainContext.insert(course)

    return ClassContentView(course: course, startsOpen: true, onAdd: {})
        .modelContainer(EmptyPreviewData.container)
        .mainContainerStyling()
}
   
