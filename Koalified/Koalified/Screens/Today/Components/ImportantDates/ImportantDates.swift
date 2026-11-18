//
//  ImportantDates.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 14/11/2026.
//

import SwiftUI

/// Banner on Today with the countdowns to the next semester milestones: three equal, colour-filled tiles
/// split by thick dividers inside one bordered box. Tapping it opens the full semester dates.
struct ImportantDates: View {
    var body: some View {
        TimelineView(.everyMinute) {
            context in
            
            let upcoming = nextMileStone(from: Milestone.all, now: context.date)
            
            let colors = [
                Color.tintAmber,
                Color.tintMint,
                Color.cardSurface
            ]
            
            NavigationLink {
                ImportantDatesView()
            } label: {
                HStack(spacing: 0) {
                    ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, milestone in
                        tile(LocalizedStringKey(milestone.title), days: "\(daysUntil(milestone.date, from: context.date))d", fill: colors[index])
                        
                        if index < upcoming.count - 1 {
                            divider
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .overlay(Rectangle().strokeBorder(Color.inkBorder, lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }

    /// One milestone: its name above the days remaining, centred on a coloured fill.
    private func tile(_ title: LocalizedStringKey, days: String, fill: Color) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.fredoka(.caption, .bold))
            Text(verbatim: days)
                .font(.fredoka(.headline, .bold))
        }
        .foregroundStyle(Color.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(fill)
    }

    /// Thick vertical line between two tiles.
    private var divider: some View {
        Rectangle()
            .fill(Color.inkBorder)
            .frame(width: 2)
    }
}

#Preview {
    ImportantDates()
        .padding()
}
