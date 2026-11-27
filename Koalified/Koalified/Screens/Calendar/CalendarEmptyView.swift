//
//  CalendarEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

struct CalendarEmptyView: View {
    
    /// Called when the user taps "Import timetable".
    let onImport: () -> Void
    /// Called when the user taps "Add a class manually".
    let onAddManually: () -> Void
    
    @State var openImportSheet = false
    @State var openAddClassSheet = false
    @State var onAdded = false
    @State private var activeSheet: ActiveSheet?

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            CalendarHeader(activeSheet: $activeSheet)
                .padding(.bottom, 10)
            
            EmptyStateView(
                header1: "Welcome to your semester",
                title1: "Bring in your timetable.",
                title2: "Check it before you keep it",
                message1: "Import your timetable file or link to get your classes in one place.",
                message2: "You should review the courses, class times and any assessment data found in your import.",
                primaryTitle1: "Import timetable",
                primaryAction1: {openImportSheet = true},
                secondaryTitle: "Add a class manually",
                secondaryAction: {openAddClassSheet = true}
            ).containerStyling()
        }
        .padding(.top, Layout.screenPadding)
        .mainContainerStyling()
            .addMenuSheets($activeSheet)
            .sheet(isPresented: $openImportSheet) {
                ImportLinkSheet().sheetBorder()
            }
            .sheet(isPresented: $openAddClassSheet) {
                AddClassSheet(onAdded: {onAdded = true}).sheetBorder()
            }
            .PopUp(isPresented: $onAdded, message: "Class Added successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        
    }
}

#Preview {
    CalendarEmptyView(onImport: {}, onAddManually: {})
}
