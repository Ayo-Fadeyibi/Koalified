//
//  WalletEmptyView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

struct WalletEmptyView: View {
    
    @State var openAssessmentSheet = false
    @State var openAddClassSheet = false
    @State var onAdded = false
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            WalletHeader()
                .padding(.bottom, 10)
            
            EmptyStateView(
                header1: "Welcome to your semester",
                title1: "A fresh set of tickets.",
                title2: "Start with the essentials",
                message1: "Add an assessment, or import a file that includes your deadlines.",
                message2: "Course, assessment name, due date and weight. Missing details can be added later.",
                primaryTitle1: "Add an assessment",
                primaryAction1: {openAssessmentSheet = true},
                secondaryTitle: "Import from Course Profile",
                secondaryAction: {openAddClassSheet = true}
            ).containerStyling()
        }
        .padding(.top, Layout.screenPadding)
        .mainContainerStyling()
            .sheet(isPresented: $openAddClassSheet) {
                ImportLinkSheet().sheetBorder()
            }
            .sheet(isPresented: $openAssessmentSheet) {
                AddAssessmentSheet(onAdded: {onAdded = true}).sheetBorder()
            }
            .PopUp(isPresented: $onAdded, message: "Class Added successfully", image: "circle-check", colour: Color.mintFill, feedback: .success)
        
    }
    
}


#Preview {
    WalletEmptyView()
}
