//
//  RootView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    
    var body: some View{
        if hasOnboarded {
            TabView {
                
                Tab("Today", systemImage: "calendar") {
                    TodayView()
                }
                
                Tab ("Courses", systemImage: "book") {
                    CoursesView()
                }
                
                Tab ("Calculator", image: "calculator") {
                    CalculatorView()
                }
                
                Tab ("Profile", systemImage: "person") {
                    ProfileView()
                }
            }.tint(Color.accentText)
        } else {
            OnboardingFlow()
        }
        
    }
}
