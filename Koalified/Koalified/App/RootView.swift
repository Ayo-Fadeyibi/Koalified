//
//  RootView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// Top-level view. Shows the main tab bar once onboarding is complete, otherwise the onboarding flow,
/// and applies the user's chosen language to the whole app.
struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("language") private var languageCode = "en"
    
    var body: some View{
        Group{
            if hasOnboarded {
                TabView {
                    
                    Tab("Today", image: "house") {
                        TodayView()
                    }
                    
                    Tab("Timetable", image: "calendar-range") {
                        CalendarTabContent()
                    }
                    
                    Tab ("Courses", image: "book-open") {
                        CoursesView()
                    }
                    
                    Tab ("Calculator", image: "calculator") {
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
