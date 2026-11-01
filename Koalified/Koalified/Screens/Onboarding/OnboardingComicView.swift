//
//  OnboardingComicView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 1/11/2026.
//

import SwiftUI
import Foundation

struct ComicPanel: Identifiable {
    let id = UUID()
    let imageName: String
    let caption: String
    
}

struct OnboardingComicView: View {
    @State private var pageNumber = 0
    
    let onFinish: () -> Void
    
    let panels = [
        ComicPanel(imageName: "comic_01_chaos", caption: "Too many apps, Too many tabs."),
        ComicPanel(imageName: "comic_01_chaos", caption: "Something Something."),
        ComicPanel(imageName: "comic_01_chaos", caption: "Ice on my wrist.")
    ]
    
    var body: some View {
        VStack{
            
            TabView(selection: $pageNumber) {
                
                ForEach(panels.indices, id: \.self) {index in
                    
                        ComicPanelView(imageName: panels[index].imageName, caption: panels[index].caption).tag(index)
                    
                }
                
            }.tabViewStyle(.page(indexDisplayMode: .never))
            
            PageDots(count: panels.count, current: pageNumber)
                .padding(.bottom, 24)
            
    
                PrimaryButton(title: pageNumber == panels.count - 1 ? "Get started" : "Next"){
                    if pageNumber < panels.count - 1 {
                        withAnimation {pageNumber += 1 }
                    } else {
                        onFinish()
                    }
                }.padding(.horizontal)
            
        }.background(Color.canvas.ignoresSafeArea())
            .overlay(alignment: .topTrailing) { SecondaryButton(title: "Skip") {onFinish()}
                    .frame(width: 100, height: 40).padding(.horizontal, 16)
                    .opacity(pageNumber < panels.count - 1 ? 1 : 0)
                    .disabled(pageNumber == panels.count - 1)
            }
    }
}

#Preview {
    OnboardingComicView(){}
}
