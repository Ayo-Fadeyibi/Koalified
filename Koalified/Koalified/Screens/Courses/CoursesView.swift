//
//  CoursesView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//


import SwiftUI
import SwiftData

enum CoursesDestination: Hashable {
    case assessmentWallet
}

struct CoursesView: View {
    @Query private var courses: [Course]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddCourse = false
    @State private var showAdded = false
    
    @State private var showImport = false

    @State var path = NavigationPath()
    
    var body: some View{
        NavigationStack (path: $path){
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 16) {
                    CoursesHeader()
                        .padding(.bottom, 10)
                    
                    if courses.isEmpty {
                        CoursesEmptyView(onAdd: {showAddCourse = true}, onImport: {showImport = true})
                    } else {
                        CoursesContent(path: $path)
                    }
                }
                .padding([.horizontal, .top], Layout.screenPadding)
                .padding(.bottom, courses.isEmpty ? Layout.screenPadding : 0)
                // With courses, let the list run behind the tab bar instead of stopping above it.
                .ignoresSafeArea(edges: courses.isEmpty ? [] : .bottom)
                .background(Color.screenBackground)
                
                FloatingAddButton(accessibilityLabel: "Add a course") {
                    showAddCourse = true
                }
                .padding(40)

            } .background(Color.screenBackground)
                .sensoryFeedback(.impact(weight: .medium), trigger: showAddCourse) { _, newValue in
                    newValue
                }
                .sheet(isPresented: $showAddCourse) { AddCourseSheet(onSaved: { showAdded = true }).sheetBorder() }
                .sheet(isPresented: $showImport) { ImportLinkSheet().sheetBorder() }
                .PopUp(isPresented: $showAdded, message: "Course added successfully", image: "circle-check", colour: Color.mintFill)
                .toolbar(.hidden, for: .navigationBar)
                .profileDestination()
                .navigationDestination(for: Course.self) { course in
                    CourseDetailView(course: course)
                        
                }
                .navigationDestination(for: CoursesDestination.self) { destination in
                    switch destination {
                    case .assessmentWallet:
                        WalletView()
                    }
                }

        }
    }
    
}



#Preview("With courses") {
    CoursesView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    CoursesView().modelContainer(EmptyPreviewData.container)
}
