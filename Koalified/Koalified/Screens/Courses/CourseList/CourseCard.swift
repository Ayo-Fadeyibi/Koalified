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
            Card {
                HStack(alignment: .top, spacing: 14) {

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(code)
                                .font(.fredoka(.headline))
                                .foregroundStyle(accent)
                            Spacer()
                            Button {
                                showFolder.toggle()
                            } label: {
                                Image(showFolder ? "folder-open" : "folder-closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(Color.textPrimary)
                            }
                        }

                        Text(title)
                            .font(.fredoka(.footnote))
                            .foregroundStyle(Color.textPrimary)

                        ProgressView(value: earned, total: 100)
                            .tint(Color.mintFill)

                        HStack {
                            Text("\(Int(earned)) of 100 points earned so far")
                                .font(.fredoka(.caption))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }

                // Spans the whole card, under both the badge and the details.
                HStack(spacing: 8) {
                    actionButton("Edit", action: onEdit)
                    actionButton("View") {
                        onView()
                        path.append(course)
                    }
                    actionButton("Delete", color: Color.errorText, action: onDelete)
                }
                
                if showFolder {
                    VStack{
                        SecondaryButton(title: "Assessments"){}
                        SecondaryButton(title: "Course timetable"){}
                    }
                    
                }
            }
        }
    }

    /// Compact bordered button that stays on one line. Three of them share the card width equally.
    private func actionButton(_ title: LocalizedStringKey,
                              color: Color = Color.textPrimary,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.fredoka(.subheadline, .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .neoBrutalist(backgroundColor: Color.cardSurface,
                              cornerRadius: Layout.radiusSmall,
                              shadowOffset: 0,
                              shadowColor: .clear)
        }
        .buttonStyle(.plain)
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
