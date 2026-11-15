//
//  TargetGradeCard.swift
//  Koalified
//

import SwiftUI

/// "Target grade" card: pick which passing grade (4–7) to aim for.
struct TargetGradeCard: View {
    @Binding var targetGrade: Int

    private let grades = GradeData.grades.filter { $0 >= 4 }

    var body: some View {
        PlainCard {
            CardHeading("TARGET GRADE")

            NeoSegmentedPicker(
                options: grades.map(String.init),
                selection: Binding(
                    get: { String(targetGrade) },
                    set: { targetGrade = Int($0) ?? targetGrade }
                )
            )
        }
    }
}

#Preview {
    @Previewable @State var grade = 6
    TargetGradeCard(targetGrade: $grade)
        .padding()
}
