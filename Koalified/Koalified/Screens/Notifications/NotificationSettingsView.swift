//
//  NotificationSettings.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 15/11/2026.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @State private var isToggleAssessmentReminder = false
    @State private var selectedNumber = 5
    @State private var isToggleClassReminder = false
    @State private var selectedClassNumber = 5
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Notifications")
                .primaryTextStyling()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    PlainCard {
                        Text("A nudge before it's due")
                            .font(.fredoka(.title2, .bold))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Choose the reminders you want for classes and assessments.")
                            .secondaryTextStyling()
                    }
                    .appearAnimation(order: 0)
                    
                    PlainCard {
                        Text("Controls")
                            .font(.fredoka(.title3, .bold))
                            .foregroundStyle(Color.textPrimary)
                        
                        Toggle(isOn: $isToggleAssessmentReminder.animation(.easeInOut(duration: 0.2))) {
                            Text("Assessment reminders")
                                .font(.fredoka(.body, .bold))
                                .foregroundStyle(Color.textPrimary)
                        }.padding()
                            .plainStyling()
                        
                        // Only offer a lead time while the matching reminder is on
                        if isToggleAssessmentReminder {
                            HStack {
                                Text("Default reminder (days)")
                                    .font(.fredoka(.body, .bold))
                                    .foregroundStyle(Color.textPrimary)
                                
                                Spacer()
                                
                                FloatingDropdown(options: Array(1...50), selection: $selectedNumber, optionLabel: { String($0) })
                                    .frame(width: 90)
                            }
                            // The dropdown carries its own padding, so trim the row's to match the toggle rows' height
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .plainStyling()
                            // Keeps the open menu floating above anything below this row
                            .zIndex(10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        Toggle(isOn: $isToggleClassReminder.animation(.easeInOut(duration: 0.2))) {
                            Text("Class reminders")
                                .font(.fredoka(.body, .bold))
                                .foregroundStyle(Color.textPrimary)
                        }.padding()
                            .plainStyling()
                        
                        if isToggleClassReminder {
                            HStack {
                                Text("Before class (hours)")
                                    .font(.fredoka(.body, .bold))
                                    .foregroundStyle(Color.textPrimary)
                                
                                Spacer()
                                
                                FloatingDropdown(options: Array(1...50), selection: $selectedClassNumber, optionLabel: { String($0) })
                                    .frame(width: 90)
                            }
                            // The dropdown carries its own padding, so trim the row's to match the toggle rows' height
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .plainStyling()
                            // Keeps the open menu floating above anything below this row
                            .zIndex(5)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    // Floats the open menus above the footnote below the card
                    .zIndex(1)
                    .appearAnimation(order: 1)
                    
                    Text("Device permissions control whether alerts can appear. Changes apply to future reminders.")
                        .secondaryTextStyling()
                        .appearAnimation(order: 2)
                }
                // Room for the last dropdown's menu to open without being clipped by the scroll view
                .padding(.bottom, 300)
            }
            .scrollIndicators(.hidden)
            
        }.mainContainerStyling()
        
    }
}

#Preview {
    NotificationSettingsView()
}
