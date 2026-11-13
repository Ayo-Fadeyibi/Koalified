import SwiftUI
import SwiftData

/// The Courses tab when courses exist: a "My courses / Degree plan" switch, filter chips
/// (Current, Past, All) and a scrolling list of course cards that link to each course's detail.
struct CoursesContent: View {
    /// Which segment is showing: "My courses" or "Degree plan".
    @State private var selectedView = "My courses"
    /// The selected filter chip: "Current", "Past" or "All".
    @State private var filter = "Current"
    
    @Binding var path: NavigationPath
    

    let options = ["My courses", "Degree plan"]
    let filters = ["Current", "Past", "All"]
    
    @Query private var courses: [Course]
    
    private var newestFirst: [Course] {
        courses.sorted {
            $0.year == $1.year ? $0.term.sortOrder > $1.term.sortOrder : $0.year > $1.year
        }
    }
    
    private var visibleCourses: [Course] {
        guard let newest = newestFirst.first else { return [] }
        switch filter {
        case "Current":
            return courses.filter{$0.year == newest.year && $0.term == newest.term}
        case "Past":
            return courses.filter{$0.year != newest.year || $0.term != newest.term}
        default:
            return newestFirst
        }
    }
    
    private struct SemesterSection: Identifiable {
        let id: String
        let title: String
        let courses: [Course]
    }
    
    private var sections: [SemesterSection] {
        let groups = Dictionary(grouping: visibleCourses, by: { SemesterKey(term: $0.term, year: $0.year) })
        let keys = groups.keys.sorted {
            let year0 = $0.year ?? 0
            let year1 = $1.year ?? 0
            if year0 != year1 { return year0 > year1 }
            return ($0.term?.sortOrder ?? 0) > ($1.term?.sortOrder ?? 0)
        }
        
        return keys.compactMap { key in
            guard let term = key.term, let year = key.year else { return nil }
            return SemesterSection(
                id: "\(term.rawValue)-\(year)",
                title: "\(term.label), \(year)",
                courses: groups[key] ?? []
            )
        }
    }

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
                        CourseFilterChip(title: title, isSelected: filter == title) { filter = title }
                    }
                }

                ScrollView {
                    // Section header
                    ForEach(sections) { section in
                        HStack { Text(section.title)
                                .font(.fredoka(.headline))
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                            Text("\(section.courses.count) courses")
                                .font(.fredoka(.footnote))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .padding(.top, 4)
                        
                        ForEach(section.courses) { course in
                        
                                CourseCard(
                                    code: course.courseCode,
                                    title: course.title ?? "",
                                    accent: course.color.color,
                                    earned: course.earnedPoints,
                                    course: course,
                                    onView: {path.append(course)}
                                )
                          
                        }
                    }.scrollIndicators(.hidden)
                    
                }
            } else {
                Text("Degree plan")
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


#Preview {
    ScrollView {
        CoursesContent(path: .constant(NavigationPath()))
            .padding(16)
    }
    .background(Color.screenBackground)
    .modelContainer(PreviewData.container)
}
