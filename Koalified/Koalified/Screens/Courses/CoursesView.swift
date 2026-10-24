//
//  CoursesView.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//


 import SwiftUI

struct CoursesView: View {
    
    var body: some View{
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                CoursesHeader()
                    .padding(.bottom, 10)
                
                if SampleData.classEvents.isEmpty {
                    CoursesEmptyView()
                } else {
                    CoursesContent()
                }
            }.padding(16)
            .background(Color.canvas)
            
            Button {
                print("Something")
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.inkPop, in: Capsule())
                
            }.padding(40)
        }
        
    }
}

#Preview {
    CoursesView()
}
