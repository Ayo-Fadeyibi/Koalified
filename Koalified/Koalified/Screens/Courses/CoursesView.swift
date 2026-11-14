//
//  CoursesView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//


import SwiftUI
import SwiftData

/// The Courses tab. Shows the header and either the empty state or the list of courses,
/// with a floating "+" button that opens the Add Course sheet. Tapping a course opens its detail screen.
struct CoursesView: View {
    @Query private var courses: [Course]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddCourse = false
    
    @State var path = NavigationPath()
    
    var body: some View{
        NavigationStack (path: $path){
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    CoursesHeader()
                        .padding(.bottom, 10)
                    
                    if courses.isEmpty {
                        CoursesEmptyView(onAdd: addTestCourse)
                    } else {
                        CoursesContent(path: $path)
                    }
                }
                .padding([.horizontal, .top], Layout.screenPadding)
                .padding(.bottom, courses.isEmpty ? Layout.screenPadding : 0)
                // With courses, let the list run behind the tab bar instead of stopping above it.
                .ignoresSafeArea(edges: courses.isEmpty ? [] : .bottom)
                .background(Color.screenBackground)
                
                Button {
                    showAddCourse = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(Color.onMint)
                        .frame(width: Layout.fabSize, height: Layout.fabSize)
                        .neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: Layout.fabSize / 2)
                    
                }.padding(40)
            } .background(Color.screenBackground)
                .sheet(isPresented: $showAddCourse) { AddCourseSheet() }
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: Course.self) { course in
                    CourseDetailView(course: course)
                        
                }
        }
    }
    
    /// Temporary helper: inserts a sample CSSE1001 course so the list can be tested.
    private func addTestCourse(){
        modelContext.insert(Course(courseCode: "CSSE1001", term: .S2, year: 2026, color: .teal))
    }
}



#Preview("With courses") {
    CoursesView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    CoursesView().modelContainer(EmptyPreviewData.container)
}
