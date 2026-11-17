//
//  CalculatorView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI
import SwiftData

/// The Calculator tab. Shows the title and either the empty state (no courses yet) or the grade calculator.
struct CalculatorView: View {
    @Query private var courses: [Course]

    @State private var showAddCourse = false
    @State private var showImport = false
    @State private var showAdded = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                CalculatorHeader()

                if courses.isEmpty {
                    CalculatorEmptyView(onAddCourse: { showAddCourse = true },
                                        onImport: { showImport = true })
                } else {
                    CalculatorContent()
                }
            }
            .mainContainerStyling()
            .background(Color.screenBackground)
            .toolbar(.hidden, for: .navigationBar)
            .profileDestination()
            .sheet(isPresented: $showAddCourse) { AddCourseSheet(onSaved: { showAdded = true }).sheetBorder() }
            .PopUp(isPresented: $showAdded, message: "Course added successfully", image: "circle-check", colour: Color.mintFill)
            .sheet(isPresented: $showImport) { ImportFlowView().sheetBorder() }
        }
    }
}

#Preview("With courses") {
    CalculatorView().modelContainer(PreviewData.container)
}

#Preview("Empty") {
    CalculatorView().modelContainer(EmptyPreviewData.container)
}
