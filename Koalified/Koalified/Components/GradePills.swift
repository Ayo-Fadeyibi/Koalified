//
//  GradePills.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// A horizontally scrolling row of "Grade n" pills; the selected one is tinted.
struct GradePills: View {
    let grades: [Int]
    @Binding var selection: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(grades, id: \.self) { grade in
                    Button {
                        selection = grade
                    } label: {
                        Text("Grade \(grade)")
                            .font(.fredoka(.subheadline, .bold))
                            .foregroundStyle(Color.greenDeep)
                            .boxStyling(bgColor: grade == selection ? Color.tintMint : Color.cardSurface,
                                        cRadius: Layout.radiusSmall, sColor: Color.cardBorder, lWidth: 1)
                    }
                }
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    @Previewable @State var grade = 5
    GradePills(grades: GradeData.grades, selection: $grade)
        .padding()
}
