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
    
    var body: some View{
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    CoursesHeader()
                        .padding(.bottom, 10)
                    
                    if courses.isEmpty {
                        CoursesEmptyView(onAdd: addTestCourse)
                    } else {
                        CoursesContent()
                    }
                }.padding(Layout.screenPadding)
                .background(Color.canvas)
                
                Button {
                    showAddCourse = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.inkPop, in: Capsule())
                    
                }.padding(40)
            } .background(Color.canvas)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: Course.self) { course in
                    CourseDetailView(course: course)
                }
            .sheet(isPresented: $showAddCourse) { AddCourseSheet() }
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
