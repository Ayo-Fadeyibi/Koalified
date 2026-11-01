//
//  ComicPanelView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 1/11/2026.
//

import SwiftUI

struct ComicPanelView: View {
    
    let imageName: String
    let caption: String
    
    var body: some View {
        
        ZStack{
            VStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .top)
                
                
                Card {
                    Text(caption)
                        .font(.fredoka(.title3, .semibold))
                }
                
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.canvas.ignoresSafeArea())
        
        
    }
}

#Preview {
    ComicPanelView(imageName: "comic_01_chaos", caption: "Too many apps. Too many tabs.")
}
