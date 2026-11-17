//
//  NextClassCard.swift
//  Koalified
//

import SwiftUI
import SwiftData

/// The highlighted card at the top of the agenda: the next class, when it starts, where it is,
/// and a button for class details and directions. Shows sample data for now.
struct NextClassView: View {
   var sessions: [ClassSession]

    /// Bumped on pull to refresh: re-reads the clock, so a finished class gives way to the next upcoming one,
    /// and flips the room board again.
    @State private var refreshCount = 0
    
    private var findTodaySession: [ClassSession] {
        findTodaysSessions(from: sessions)
    }
    
    private var upcomingSessions: [ClassSession] {
        findUpcomingSessions(from: sessions)
    }

    private var nextSession: ClassSession? {
        upcomingSessions.first
    }

    /// The sessions after the next one, for the list below the card.
    private var laterSessions: [ClassSession] {
        Array(upcomingSessions.dropFirst())
    }
    
    

    var body: some View {
        VStack{
            if nextSession == nil && findTodaySession.isEmpty {
                NoClassView(onImport: {}, onAddManually: {})
            } else if nextSession == nil {
                AllDoneToday()
            } else {
                Card(bgColor: Color.tintMint) {
                    VStack(alignment: .leading, spacing: 14) {

                        // Header: label on the left, live countdown on the right
                        HStack(alignment: .center) {
                            Text("NEXT CLASS")
                                .font(.fredoka(.caption, .semibold))
                                .foregroundStyle(Color.textSecondary)

                            Spacer()

                            // Refreshes every minute so the countdown stays current
                            TimelineView(.periodic(from: .now, by: 60)) { context in
                                Text(verbatim: countdownLabel(to: nextSession, now: context.date))
                                    .font(.fredoka(.caption, .bold))
                                    .foregroundStyle(Color.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .plainStyling()
                            }
                        }

                        // Title: course code on its own line, then class type and time beneath
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: nextSession?.course?.courseCode ?? "")
                                .font(.fredoka(.title2, .bold))
                                .foregroundStyle(Color.textPrimary)

                            Text(nextSession?.type.label ?? SessionType.unknown.label)
                                .font(.fredoka(.subheadline, .semibold))
                                .foregroundStyle(Color.accent)
                            + Text(verbatim: "  ·  \(timeRange(from: nextSession))")
                                .font(.fredoka(.subheadline, .semibold))
                                .foregroundStyle(Color.textSecondary)
                        }

                        // Room code on the flap display, with the building underneath
                        VStack(alignment: .leading, spacing: 8) {
                            SplitFlapDisplay(text: nextSession?.room ?? "", replayTrigger: refreshCount)

                            if let building = nextSession?.building {
                                Label(building, systemImage: "mappin.and.ellipse")
                                    .font(.fredoka(.subheadline, .semibold))
                                    .foregroundStyle(Color.textPrimary)
                                    .padding()
                                    .plainStyling()
                                    
                            }
                        }

                        // Button
                        PlainPrimaryButton(title: "Walk there in Apple Maps"){}
                    }
                }
                // Only the later classes scroll; the banner and next-class card stay put.
                // The bottom padding keeps the last row clear of the + button and tab bar.
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(laterSessions) { session in
                            TodayClassRow(event: session)
                        }
                    }
                    .padding(.bottom, 140)
                }
                .scrollIndicators(.hidden)
                // Pull down to refresh: moves on to the next upcoming class if the current one has ended.
                .scrollBounceBehavior(.always)
                .refreshable {
                    refreshCount += 1
                    // Hold the spinner while the board flips
                    try? await Task.sleep(for: .milliseconds(600))
                }
            }
            }
        
        
        
    }
}

#Preview {
    let start = Date().addingTimeInterval(20 * 60)
    let sessions = [
        ClassSession(start: start,
                     end: start.addingTimeInterval(60 * 60),
                     type: .LEC,
                     room: "50-201",
                    building: "Hawken Engineering Building"
                    )
    ]
    return NextClassView(sessions: sessions)
        .padding()
        .modelContainer(PreviewData.container)
}
