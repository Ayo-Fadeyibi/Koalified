import SwiftUI
import SwiftData

/// The Courses tab when courses exist: a "My courses / Degree plan" switch, one row with the semester
/// picker and a wallet shortcut, then a scrolling list of course cards that link to each course's detail.
struct CoursesContent: View {
    /// Which segment is showing: "My courses" or "Degree plan".
    @State private var selectedView = "My courses"

    @Binding var path: NavigationPath

    let options = ["My courses", "Degree plan"]

    @Query private var courses: [Course]

    /// The semester picked in the dropdown; nil until `selectNewestSemester` runs.
    @State private var selectedSemester: SemesterChoice?

    /// The courses in the picked semester.
    private var shownCourses: [Course] {
        guard let selectedSemester else { return [] }
        return courses.filter(selectedSemester.contains)
    }

    /// Starts the dropdown on the newest semester that has courses, and moves back to it when the
    /// picked semester no longer has any (e.g. after Delete semester data).
    private func selectNewestSemester() {
        let choices = courses.semesterChoices
        if let selectedSemester, choices.contains(selectedSemester) { return }
        selectedSemester = choices.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NeoSegmentedPicker(options: options, selection: $selectedView)

            if selectedView == "My courses" {
                HStack(alignment: .top, spacing: 10) {
                    // Only semesters that have courses, so every choice shows something.
                    FloatingDropdown(options: courses.semesterChoices.map { Optional($0) },
                                     selection: $selectedSemester) { semester in
                        semester?.label ?? ""
                    }

                    walletButton
                }
                .padding(.bottom, 8)
                // A dropdown's zIndex only orders it among its own siblings, so the row
                // must sit above the list below it for the menu to float on top.
                .zIndex(1)

                ScrollView {
                    // Folders have no shadow to separate them, so space them out here.
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(shownCourses) { course in
                            CourseCard(course: course, onView: { path.append(course) })
                        }
                        // Lets the last card scroll clear of the add button and tab bar
                        Color.clear.frame(height: 140)
                    }
                }.scrollIndicators(.hidden)
            } else {
                Text("Degree plan")
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear(perform: selectNewestSemester)
        .onChange(of: courses.semesterChoices) { selectNewestSemester() }
    }

    /// A small shortcut to the assessment wallet, styled to sit beside the semester dropdown.
    private var walletButton: some View {
        Button {
            path.append(CoursesDestination.assessmentWallet)
        } label: {
            Label("Wallet", systemImage: "wallet.pass")
                .font(.fredoka(.body, .bold))
                .foregroundStyle(Color.textPrimary)
                .padding()
                .background(Color.tintMint)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.radiusSmall - 4)
                        .stroke(Color.inkBorder, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .fixedSize()
        .accessibilityLabel(Text("Open assessment wallet"))
    }
}


#Preview {
    CoursesView()
        .modelContainer(PreviewData.container)
}
