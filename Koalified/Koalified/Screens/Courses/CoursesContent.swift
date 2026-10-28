import SwiftUI
import SwiftData

/// The Courses tab when courses exist: a "My courses / Degree plan" switch, filter chips
/// (Current, Past, All) and a scrolling list of course cards that link to each course's detail.
struct CoursesContent: View {
    /// Which segment is showing: "My courses" or "Degree plan".
    @State private var selectedView = "My courses"
    /// The selected filter chip: "Current", "Past" or "All".
    @State private var filter = "Current"

    let options = ["My courses", "Degree plan"]
    let filters = ["Current", "Past", "All"]
    
    @Query private var courses: [Course]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Courses view", selection: $selectedView) {
                ForEach(options, id: \.self) { option in
                    Text(LocalizedStringKey(option))
                }
            }
            .pickerStyle(.segmented)

            if selectedView == "My courses" {
                // Filter chips
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { title in
                        chip(title)
                    }
                }

                ScrollView {
                    // Section header
                    HStack {
                        Text("Semester 2, 2026 · Current")
                            .font(.headline)
                            .foregroundStyle(Color.inkPrimary)
                        Spacer()
                        Text("\(courses.count) courses")
                            .font(.footnote)
                            .foregroundStyle(Color.inkSecondary)
                    }
                    .padding(.top, 4)
                    
                    ForEach(courses) { course in
                        NavigationLink(value: course) {
                            courseCard(
                                code: course.courseCode,
                                title: course.title ?? "",
                                accent: course.color.color,
                                earned: course.earnedPoints
                            )
                        }.buttonStyle(.plain)
                    }
                }.scrollIndicators(.hidden)
            } else {
                Text("Degree plan")
                    .foregroundStyle(Color.inkPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Pieces

    /// A pill-shaped filter button; filled when it is the selected filter.
    private func chip(_ title: String) -> some View {
        let isSelected = filter == title
        return Button {
            filter = title
        } label: {
            Text(LocalizedStringKey(title))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.inkPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.inkPop : Color.surface, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    /// Card for one course: a coloured code badge, title, progress bar and points earned out of 100.
    /// The "On track" badge is static for now.
    private func courseCard(code: String, title: String, accent: Color, earned: Double) -> some View {
        Card {
            HStack(alignment: .top, spacing: 14) {
                // Badge: first four letters of the code
                Text(String(code.prefix(4)))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
                    .frame(width: 52, height: 52)
                    .background(accent.opacity(0.15), in: RoundedRectangle(cornerRadius: Layout.radiusSmall))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(code)
                            .font(.headline)
                            .foregroundStyle(accent)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.inkPrimary)
                    }

                    Text(title)
                        .font(.footnote)
                        .foregroundStyle(Color.inkPrimary)

                    ProgressView(value: earned, total: 100)
                        .tint(accent)

                    HStack {
                        Text("\(Int(earned)) of 100 points earned so far")
                            .font(.caption)
                            .foregroundStyle(Color.inkSecondary)
                        Spacer()
                        Text("On track")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.accentText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .overlay {
                                Capsule()
                                    .strokeBorder(Color.accentText, lineWidth: 1)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        CoursesContent()
            .padding(16)
    }
    .background(Color.canvas)
    .modelContainer(PreviewData.container)
}
