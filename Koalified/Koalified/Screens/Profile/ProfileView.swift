//
//  ProfileView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI
import SwiftData

/// The Profile tab. Placeholder for now.
struct ProfileView: View {
    @Query private var courses: [Course]
    
    private var trigger = false

    // No NavigationStack here: ProfileView is pushed from a tab's existing stack (via ProfileAvatarButton),
    // and a nested stack stops these value-based links from working on device.
    var body: some View {
        VStack {
            ProfileHeader()

             if trigger {
                 ProfileEmptyView()
             } else {
                 ProfileContentView()
             }
        }.mainContainerStyling()
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationSettingsView()
                case .language:
                    LanguageSettingsView()
                case .replayTour:
                    OnboardingComicView(onFinish: {})
                case .addWidget:
                    WidgetGuideView()
                case .semesterReceipt:
                    SemesterReceiptView()
                case .about:
                    AboutKoalifiedView()
                case .helpFeedback:
                    HelpFeedbackView()
                case .reviewCourses:
                    ReviewCoursesView()
                case .removeLink:
                    RemoveTimetableLinkView()
                case .deleteData:
                    DeleteSemesterDataView()
                }
            }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
