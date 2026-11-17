//
//  Popup.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 17/11/2026.
//

import SwiftUI

private struct Popup: ViewModifier {
    
    @Binding var isPresented: Bool
    var message: LocalizedStringKey? = nil
    let image: String
    let colour: Color
    var feedback: SensoryFeedback = .success

    func body (content: Content)-> some View {
     
        content
            .overlay{
                if isPresented {
                    ZStack {
                        // 1. Dimmed backdrop
                        Color.black.opacity(0.45)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    isPresented = false
                                }
                            }

                        // 2. Focal-point Neo-Brutalist Pop-up Card
                        Card {
                            VStack(spacing: 16) {
                                // Bordered icon badge
                                Image(image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(Color.black)
                                    .padding(16)
                                    .background(colour)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.black, lineWidth: 1.5)
                                    )

                                if let message {
                                    Text(message)
                                        .font(.fredoka(.title3, .bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                // Optional quick dismiss button
                                Button {
                                    withAnimation(.snappy(duration: 0.2)) {
                                        isPresented = false
                                    }
                                } label: {
                                    Text("Got it")
                                        .font(.fredoka(.subheadline, .bold))
                                        .foregroundStyle(Color.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(colour)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.black, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: 310) // Prevents full-screen stretch on wider iPhones
                        .padding(.horizontal, 24)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                    
                }

            
        }.animation(.spring(response: 0.3, dampingFraction: 0.72), value: isPresented)
            .sensoryFeedback(feedback, trigger: isPresented) { _, newValue in
                newValue
            }

    }
}

extension View{
    
    func PopUp (isPresented: Binding<Bool>, message: LocalizedStringKey? = nil, image: String, colour: Color, feedback: SensoryFeedback = .success) -> some View {
        self.modifier(Popup(isPresented: isPresented, message: message, image: image, colour: colour, feedback: feedback))
    }
}

#Preview {
    @Previewable @State var showPopup = true

    Button("Show popup") { showPopup = true }
        .PopUp(isPresented: $showPopup, message: "Course added successfully", image: "circle-check", colour: .accent)
}
