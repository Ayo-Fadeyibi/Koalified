//
//  RootView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

enum AppTab: Hashable {
    case today, timetable, courses, calculator
}

/// Top-level view. Shows the main tab bar once onboarding is complete, otherwise the onboarding flow,
/// and applies the user's chosen language to the whole app.
struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("language") private var languageCode = "en"
    
    @State private var selectedTab: AppTab = .today
    
    var body: some View{
        Group{
            if hasOnboarded {
                TabView(selection: $selectedTab) {
                    
                    Tab("Today", image: "house", value: AppTab.today) {
                        TodayView(selectedTab: $selectedTab)
                    }
                    
                    Tab("Timetable", image: "calendar-range", value: AppTab.timetable) {
                        CalendarTabContent()
                    }
                    
                    Tab ("Courses", image: "book-open", value: AppTab.courses) {
                        CoursesView()
                    }
                    
                    Tab ("Calculator", image: "calculator", value: AppTab.calculator) {
                        CalculatorView()
                    }
                    
                }.tint(Color.accent)
            } else {
                OnboardingFlow()
            }
            
        }
        // Default font for any text that doesn't set its own.
        .font(.fredoka(.body))
        .environment(\.locale, Locale(identifier: languageCode))
    }
}
