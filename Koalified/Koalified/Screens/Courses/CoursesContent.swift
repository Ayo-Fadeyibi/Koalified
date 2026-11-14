import SwiftUI
import SwiftData

/// The Courses tab when courses exist: a "My courses / Degree plan" switch, year and term
/// dropdowns, and a scrolling list of course cards that link to each course's detail.
struct CoursesContent: View {
    /// Which segment is showing: "My courses" or "Degree plan".
    @State private var selectedView = "My courses"

    @Binding var path: NavigationPath

    let options = ["My courses", "Degree plan"]

    @Query private var courses: [Course]
    
    /// The semester and year picked in the dropdowns.
    @State private var selectedTerm: Term = .S1
    @State private var selectedYear = Calendar.current.component(.year, from: .now)

    /// Sections for the courses in the selected year and term.
    private var sections: [SemesterSection] {
        courses
            .filter { $0.year == selectedYear && $0.term == selectedTerm }
            .semesterSections
    }

    /// Starts the dropdowns on the newest semester that has courses.
    private func selectNewestSemester() {
        guard let newest = courses.newestFirst.first else { return }
        selectedYear = newest.year
        selectedTerm = newest.term
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NeoSegmentedPicker(options: options, selection: $selectedView)

            if selectedView == "My courses" {
                HStack {
                    FloatingDropdown(options: courses.availableYears, selection: $selectedYear) { year in
                        String(year)
                    }

                    Spacer()

                    FloatingDropdown(options: courses.availableSemesters, selection: $selectedTerm) { term in
                        term.label
                    }
                }.padding(.bottom, 20)
                // A dropdown's zIndex only orders it among its own siblings, so the row
                // must sit above the button and list below it for the menu to float on top.
                .zIndex(1)

                PrimaryButton(title: "Assessment Wallet"){}
                    .padding(.bottom, 20)

                ScrollView {
                    // Section header
                    ForEach(sections) { section in
                        SemesterSectionView(section: section, path: $path)
                    }
                    // Lets the last card scroll clear of the + button and tab bar
                    Color.clear.frame(height: 140)
                }.scrollIndicators(.hidden)
            } else {
                Text("Degree plan")
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear(perform: selectNewestSemester)
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
