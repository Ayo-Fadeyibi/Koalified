import SwiftUI
import SwiftData

/// Detail screen for one course: its code and title, then either an empty state or its assessments.
/// Offers sheets to add an assessment and (via the Edit button) to edit the course.
struct CourseDetailView: View {
    let course: Course
    @State private var showAddAssessment = false
    @State private var showEditCourse = false
    @State private var showAddClass = false
    
    @State var onAddedAssessment = false
    @State var onAddedAClass = false
    @State var onEditCourse = false

    /// The assessment whose mark is being entered in the add-mark pop-up, if any.
    @State private var markingItem: AssessmentItem?
    @State private var onAddedMark = false
    /// Whether the open pop-up is changing a mark that already existed, for the success message.
    @State private var isEditingMark = false

    var body: some View {
        Group {
            if course.assessments.isEmpty {
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    header
                    ScrollView {
                        CourseGraph(course: course)
                        AssessmentsContentView(course: course,
                                               onAdd: { showAddAssessment = true },
                                               onAddMark: openMarkPopup)
                        ClassContentView(course: course, onAdd: {showAddClass = true})
                    }.scrollIndicators(.hidden)
                }
                .padding(Layout.screenPadding)
            } else {
                
                    VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                        header
                        ScrollView {
                            CourseGraph(course: course)
                            AssessmentsContentView(course: course,
                                                   onAdd: { showAddAssessment = true },
                                                   onAddMark: openMarkPopup)
                            ClassContentView(course: course, onAdd: {showAddClass = true})
                        }.scrollIndicators(.hidden)
                    }
                    .padding(Layout.screenPadding)

            }
        }
        .background(Color.screenBackground)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.impact(weight: .light), trigger: showAddAssessment)
        .sensoryFeedback(.impact(weight: .light), trigger: showAddAssessment)
        .sheet(isPresented: $showAddAssessment) {
            AddAssessmentSheet(onAdded: {onAddedAssessment = true}, currentCourse: course)
                .sheetBorder()
                .presentationDetents([.height(520)])
        }
        .sheet(isPresented: $showAddClass) {
            AddClassSheet(onAdded: {onAddedAClass = true})
                .sheetBorder()
            
        }
        .PopUp(isPresented: $onAddedAssessment, message: "Assessment Added successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        .PopUp(isPresented: $onAddedAClass, message: "Class Added successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        .PopUp(isPresented: $onEditCourse, message: "Course edited successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        .addMarkPopup(item: $markingItem, onSaved: { onAddedMark = true })
        .PopUp(isPresented: $onAddedMark, message: isEditingMark ? "Mark updated successfully" : "Mark added successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditCourse = true }
            }
        }
        .sheet(isPresented: $showEditCourse) {
            AddCourseSheet(course: course, onSaved: {onEditCourse = true})
                .sheetBorder()
        }
    }
    
    /// Opens the add-mark pop-up for `item`, noting whether it already had a mark.
    private func openMarkPopup(for item: AssessmentItem) {
        isEditingMark = item.mark != nil
        markingItem = item
    }

    /// Course code as a large title with the course name underneath, if it has one.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.courseCode)
                .font(.fredoka(.largeTitle, .bold))
                .foregroundStyle(Color.textPrimary)
            if let title = course.title {
                Text(title)
                    .font(.fredoka(.subheadline, .medium))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Text(course.semesterLabel)
                .font(.fredoka(.subheadline))
                .foregroundStyle(Color.textSecondary)
        }.padding(.bottom, 10)
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
