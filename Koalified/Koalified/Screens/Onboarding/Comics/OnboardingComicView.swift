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
    @Environment(\.dismiss) private var dismiss
    
    var finishTitle: LocalizedStringKey = "Done"
    
    let panels = [
        ComicPanel(imageName: "comic_01_chaos", caption: "Too many apps. Too many tabs."),
        ComicPanel(imageName: "comic_02_deadlines", caption: "Too many deadlines."),
        ComicPanel(imageName: "comic_03_hero", caption: "Koalified to the rescue."),
        ComicPanel(imageName: "comic_04_calm", caption: "Breathe. It’s all sorted.")
    ]
    
    var body: some View {
        VStack {
            
            TabView(selection: $pageNumber) {
                
                ForEach(panels.indices, id: \.self) {index in
                    
                        ComicPanelView(imageName: panels[index].imageName, caption: panels[index].caption)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .tag(index)
                    
                }
                
            }.tabViewStyle(.page(indexDisplayMode: .never))
            
            PageDots(count: panels.count, current: pageNumber)
                .padding(.bottom, 24)
            
    
                PrimaryButton(title: pageNumber == panels.count - 1 ? finishTitle : "Next"){
                    if pageNumber < panels.count - 1 {
                        withAnimation {pageNumber += 1 }
                    } else {
                        dismiss()
                    }
                }.padding(.horizontal)
                .padding(.bottom, 48)
            
        }
        .background(Color.screenBackground.ignoresSafeArea())

    }
}

#Preview {
    OnboardingComicView()
}
