//
//  CourseCard.swift
//  Koalified
//

import SwiftUI

/// Card for one course in the list: a coloured code badge, title, progress bar and points earned out of 100,
/// with Edit / View / Delete buttons along the bottom.
/// The "On track" badge is static for now.
struct CourseCard: View {
    let code: String
    let title: String
    let accent: Color
    let earned: Double
    let course: Course
    /// Button actions. They do nothing until the caller passes them in.
    var onEdit: () -> Void = {}
    var onView: () -> Void = {}
    var onDelete: () -> Void = {}
    
    @State private var showFolder = false
    
    @State private var path = NavigationPath()

    var body: some View {
            PlainCard {
                HStack(alignment: .top, spacing: 14) {

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(code)
                                .font(.fredoka(.headline))
                                .foregroundStyle(accent)
                            
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    showFolder.toggle()
                                }
                            } label: {
                                Image(showFolder ? "folder-open" : "folder-closed")
                                    //.resizable()
                                    //.scaledToFit()
                                    .padding()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(Color.textPrimary)
                                    .neoBrutalist(backgroundColor: Color.cardSurface, cornerRadius: 5)
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.impact(weight: .light), trigger: showFolder)
                        }

                        Text(title)
                            .font(.fredoka(.footnote))
                            .foregroundStyle(Color.textPrimary)

                        ProgressView(value: earned, total: 100)
                            .tint(accent)

                        HStack {
                            Text("\(Int(earned)) of 100 points earned so far")
                                .font(.fredoka(.caption))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

              
                
                if showFolder {
                    VStack{
                        // Spans the whole card, under both the badge and the details.
                        HStack(spacing: 8) {
                            ActionButton(title: "Edit", color: Color.tintMint, action: onEdit)
                            ActionButton(title: "View") {
                                onView()
                                path.append(course)
                            }
                            ActionButton(title: "Delete", color: Color.errorText, action: onDelete)
                        }
                        
                    }
                    
                }
                
            }
    }
}

#Preview("Course cards") {
    let csse = Course(courseCode: "CSSE1001", title: "Introduction to Software Engineering",
                      term: .S2, year: 2026, color: .teal)
    let math = Course(courseCode: "MATH1051", title: "Calculus & Linear Algebra I",
                      term: .S2, year: 2026, color: .rose)
    
    ScrollView {
        VStack(spacing: 16) {
            CourseCard(code: csse.courseCode, title: csse.title ?? "", accent: csse.color.color, earned: 66, course: csse)
            CourseCard(code: math.courseCode, title: math.title ?? "", accent: math.color.color, earned: 0, course: math)
        }
        .padding(16)
    }
    .background(Color.screenBackground)
}
