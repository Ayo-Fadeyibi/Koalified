//
//  CoursesView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//


import SwiftUI
import SwiftData

struct CoursesView: View {
    @Query private var courses: [Course]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddCourse = false
    
    var body: some View{
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                CoursesHeader()
                    .padding(.bottom, 10)
                
                if courses.isEmpty {
                    CoursesEmptyView(onAdd: addTestCourse)
                } else {
                    CoursesContent()
                }
            }.padding(16)
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
        }.sheet(isPresented: $showAddCourse) { AddCourseSheet() }
        
    }
    
    private func addTestCourse(){
        modelContext.insert(Course(courseCode: "CSSE1001", term: .semester2, year: 2026, color: .teal))
    }
}



#Preview("With courses") {
    CoursesView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    CoursesView().modelContainer(EmptyPreviewData.container)
}
