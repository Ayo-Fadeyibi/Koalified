//
//  AssessmentRow.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 22/10/2026.
//

import SwiftUI

/// A card with one `AssessmentRow` per item; `trailing` builds the mark or button for each row.
struct AssessmentList<Trailing: View>: View {
    let items: [AssessmentItem]
    let trailing: (AssessmentItem) -> Trailing

    init(
        _ items: [AssessmentItem],
        @ViewBuilder trailing: @escaping (AssessmentItem) -> Trailing
    ) {
        self.items = items
        self.trailing = trailing
    }

    var body: some View {
        Card {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    AssessmentRow(item: item) { trailing(item) }
                                        if item !== items.last { Divider().padding(.horizontal, 14) }
                }
            }
        }
    }
}

/// One assessment in a list: its title, weight and due date, plus caller-supplied trailing content.
struct AssessmentRow<Trailing: View>: View {
let item: AssessmentItem
let trailing: Trailing

init(item: AssessmentItem, @ViewBuilder trailing: () -> Trailing) {
    self.item = item
    self.trailing = trailing()
}

var body: some View {
    HStack(spacing: 12) {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.inkPrimary)
            Text("\(Int(item.weight))% of course · due \(item.dueDate.formatted(.dateTime.day().month(.abbreviated)))")
                .font(.caption)
                .foregroundStyle(Color.inkSecondary)
        }
        Spacer()
        trailing
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.inkSecondary)
    }
    .padding(14)
}
}

