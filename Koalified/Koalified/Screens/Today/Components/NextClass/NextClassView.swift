//
//  NextClassCard.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// The highlighted card at the top of the agenda: the next class, when it starts, where it is,
/// and a button for class details and directions.
struct NextClassView: View {
    var sessions: [ClassSession]
    var onSeeWeek: () -> Void = {}
    let onViewAssessment: () -> Void

    /// Bumped on pull-to-refresh or board tap: re-reads the clock and flips the room board again.
    @State private var refreshCount = 0
    @Environment(\.openURL) private var openURL

    var body: some View {
        TimelineView(.everyMinute) { context in
            let now = context.date
            let todaySessions = findTodaysSessions(from: sessions, now: now)
            let upcomingSessions = findUpcomingSessions(from: sessions, now: now)

            let nextSession = upcomingSessions.first
            let laterSessions = Array(upcomingSessions.dropFirst())
            let timeLeft = countdownLabel(to: nextSession, now: now)
            let isLive = nextSession.map { $0.start <= now } ?? false

            VStack(spacing: 16) {
                if nextSession == nil && todaySessions.isEmpty {
                    NoClassView(onSeeWeek: onSeeWeek, onViewAssessment: {}, now: context.date)
                } else if nextSession == nil {
                    AllDoneToday(onSeeWeek: onSeeWeek)
                } else if let nextSession {
                    // 1. Hero Next Class Card
                    Card {
                        VStack(alignment: .leading, spacing: 14) {

                            // Header: Eyebrow label + live countdown pill
                            HStack(alignment: .center) {
                                Text(isLive ? "IN PROGRESS" : "NEXT CLASS")
                                    .font(.fredoka(.caption, .bold))
                                    .foregroundStyle(Color.textSecondary)

                                Spacer()

                                Text(verbatim: timeLeft.uppercased())
                                    .font(.fredoka(.caption, .bold))
                                    .foregroundStyle(isLive ? Color.textPrimary : Color.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(isLive ? Color.tintAmber : Color.tintMint, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                            .strokeBorder(Color.inkBorder, lineWidth: 2)
                                    )
                            }

                            // Course Code + Class Type & Time
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(verbatim: nextSession.course?.courseCode ?? "CLASS")
                                        .font(.fredoka(.title2, .bold))
                                        .foregroundStyle(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    if let building = nextSession.building, !building.isEmpty {
                                        Text(building)
                                            .font(.fredoka(.subheadline, .semibold))
                                            .foregroundStyle(Color.textPrimary)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(isLive ? Color.tintAmber : Color.tintMint, in: RoundedRectangle(cornerRadius: Layout.radiusSmall))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Layout.radiusSmall)
                                                    .strokeBorder(Color.inkBorder, lineWidth: 2)
                                            )
                                    }
                            
                                }

                                HStack(spacing: 6) {
                                    Text(nextSession.type.label)
                                        .font(.fredoka(.subheadline, .bold))
                                        .foregroundStyle(Color.accent)

                                    Text("·")
                                        .font(.fredoka(.subheadline, .bold))
                                        .foregroundStyle(Color.textSecondary)

                                    Text(verbatim: timeRange(from: nextSession))
                                        .font(.fredoka(.subheadline, .semibold))
                                        .foregroundStyle(Color.textSecondary)
                                }
                               
                            }

                            // Building Pill + Walking Directions Action
                           
                                VStack(alignment: .leading, spacing: 10) {
                                    
                                    
                                    // Split-Flap Room Board (tappable to replay mechanical clack)
                                    SplitFlapDisplay(text: nextSession.clashable == true ? "CLASH" : nextSession.room ?? "", replayTrigger: refreshCount, tileHeight: 46)
                                        .onTapGesture { refreshCount += 1 }
                                        .sensoryFeedback(.impact(weight: .light), trigger: refreshCount)
                                        .accessibilityHidden(true)

                                    if let building = nextSession.building, !building.isEmpty,
                                       let url = mapsWalkingURL(to: building) {
                                        PlainPrimaryButton(title: "Walk there in Apple Maps") {
                                            openURL(url)
                                        }
                                    }
                    
                                }
                            
                        }
                    }

                    // 2. Later Classes List (only rendered when there are more classes today)
                    if !laterSessions.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("UPCOMING TODAY")
                                    .font(.fredoka(.caption, .bold))
                                    .foregroundStyle(Color.textSecondary)
                                    .padding(.horizontal, 4)

                                ForEach(laterSessions) { session in
                                    TodayClassRow(event: session)
                                }
                            }
                            .padding(.bottom, 140)
                        }
                        .scrollIndicators(.hidden)
                        .scrollBounceBehavior(.always)
                        .refreshable {
                            refreshCount += 1
                            try? await Task.sleep(for: .milliseconds(600))
                        }
                    } else {
                        Spacer(minLength: 0)
                    }
                    
                }
            }
        }
        
    }
}

#Preview {
    let start = Date().addingTimeInterval(20 * 60)
    let sessions = [
        ClassSession(
            start: start,
            end: start.addingTimeInterval(60 * 60),
            type: .LEC,
            room: "50-201",
            building: "Hawken Engineering Building"
        ),
        ClassSession(
            start: start.addingTimeInterval(120 * 60),
            end: start.addingTimeInterval(180 * 60),
            type: .TUT,
            room: "11A-130",
            building: "ModWest"
        )
    ]
    return NextClassView(sessions: sessions, onViewAssessment: {})
        .padding()
        .modelContainer(PreviewData.container)
}
