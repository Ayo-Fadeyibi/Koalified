import SwiftUI
import SwiftData

/// Detail screen for one course: its code and title, then either an empty state or its assessments.
/// Offers sheets to add an assessment and (via the Edit button) to edit the course.
struct CourseDetailView: View {
    let course: Course
    @State private var showAddAssessment = false
    @State private var showEditCourse = false

    var body: some View {
        Group {
            if course.assessments.isEmpty {
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    header
                    Spacer()
                    AssessmentsEmptyView(onAdd: { showAddAssessment = true })
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .padding(Layout.screenPadding)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                        header
                        AssessmentsContentView(course: course,
                                               onAdd: { showAddAssessment = true })
                    }
                    .padding(Layout.screenPadding)
                }
            }
        }
        .background(Color.canvas)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddAssessment) {
            AddAssessmentSheet(course: course)
                .presentationDetents([.height(320)])
        }
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditCourse = true }
            }
        }
        .sheet(isPresented: $showEditCourse) {
            AddCourseSheet(course: course)
        }
    }
    
    /// Course code as a large title with the course name underneath, if it has one.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.courseCode)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.inkPrimary)
            if let title = course.title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.inkSecondary)
            }
        }
    }
}

#Preview("With assessments") {
    let course = try! PreviewData.container.mainContext
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "CSSE1001" }))
        .first!
    NavigationStack { CourseDetailView(course: course) }
        .modelContainer(PreviewData.container)
}

#Preview("No assessments") {
    let course = try! PreviewData.container.mainContext
        .fetch(FetchDescriptor<Course>(predicate: #Predicate { $0.courseCode == "MATH1051" }))
        .first!
    NavigationStack { CourseDetailView(course: course) }
        .modelContainer(PreviewData.container)
}
