//
//  FolderCardBackground.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 26/11/2026.
//

import SwiftUI

/// One sheet of paper sticking out of the folder: a title on the left, its kind (e.g. "EXAM") on the right.
struct FolderPaper: Identifiable {
    let id = UUID()
    let title: String
    let kind: String
    let color: Color
}

/// A folder: the back panel, papers peeking out above it, and the front panel (with its raised middle)
/// in front of them. `content` sits on the front panel, inside a dashed border.
/// When `isOpen` is false the papers slide down into the folder, leaving just their top edges showing;
/// change it inside `withAnimation` to animate.
struct FolderCardBackground<Content: View>: View {
    var color: Color = Color(red: 0.12, green: 0.34, blue: 0.26)
    /// Text and line colour on the front panel; pass `CourseColor.onColor` so bright folders get dark text.
    var ink: Color = .white
    var papers: [FolderPaper] = []
    var isOpen = true
    @ViewBuilder var content: Content

    /// How much of each paper shows above the one in front of it.
    private var paperStrip: CGFloat { isOpen ? 26 : 5 }
    /// How far the front paper shows above the front panel's raised middle.
    private var frontPaperStrip: CGFloat { isOpen ? 32 : 8 }
    /// Full height of a paper; the rest of it is hidden behind the papers and panel in front.
    private let paperHeight: CGFloat = 72
    /// How far the papers stick up past the top of the back panel when open.
    private let papersAboveBack: CGFloat = 14
    /// How far below the back panel's top edge the papers sit when tucked in, so they look inside the folder.
    private let papersBelowBack: CGFloat = 12
    /// How much lower the front panel's sides are than its raised middle.
    private let raise: CGFloat = 22
    private let radius: CGFloat = 22

    var body: some View {
        VStack(spacing: 0) {
            paperStack
                .padding(.top, isOpen || papers.isEmpty ? 0 : papersBelowBack)

            frontPanel
                // Slide the front up over the bottom of the papers, so they look tucked inside.
                .padding(.top, papers.isEmpty ? 0 : -(paperHeight - frontPaperStrip))
        }
        .background(alignment: .top) {
            // Back panel: open, it starts a little below the top paper (so the papers stand up out of it);
            // closed, it starts above them. Either way it runs to the bottom of the front.
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
                .padding(.top, isOpen && !papers.isEmpty ? papersAboveBack : 0)
        }
    }

    /// The papers, back to front: each one overlaps the one behind it, leaving a strip of it showing.
    private var paperStack: some View {
        VStack(spacing: -(paperHeight - paperStrip)) {
            ForEach(papers) { paper in
                HStack(alignment: .firstTextBaseline) {
                    Text(paper.title)
                        .font(.fredoka(.headline, .bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(paper.kind.uppercased())
                        .font(.fredoka(.caption, .bold))
                        .foregroundStyle(Color.textSecondary)
                }
                // Tucked-in papers only show a sliver, so their labels would just be cut off.
                .opacity(isOpen ? 1 : 0)
                .padding(.horizontal, 14)
                .padding(.top, 5)
                .frame(height: paperHeight, alignment: .top)
                .background(paper.color, in: UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                        .strokeBorder(Color.textSecondary.opacity(0.35), lineWidth: 1.5)
                )
            }
        }
        // Slightly narrower than the folder, so they look like they're inside it.
        .padding(.horizontal, 18)
    }

    private var frontPanel: some View {
        content
            .foregroundStyle(ink)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: radius - 8)
                    .strokeBorder(ink.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                    .padding(8)
            )
            // Room above the dashed border for the panel's raised middle.
            .padding(.top, raise + 4)
            .background(
                FolderFrontShape(corner: 10, raise: raise, shoulder: 26, inset: 0.08, bottomCorner: radius)
                    .fill(color)
            )
    }
}

#Preview {
    @Previewable @State var isOpen = true

    FolderCardBackground(papers: [
        FolderPaper(title: "Final exam", kind: "Exam", color: .tintLavender),
        FolderPaper(title: "Programming project", kind: "Project", color: .tintAmber),
        FolderPaper(title: "Assignment 1", kind: "Assignment", color: .tintMint),
    ], isOpen: isOpen) {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "CSSE1001")
                        .font(.fredoka(.largeTitle, .bold))
                    Text(verbatim: "Introduction to Software Engineering")
                        .font(.fredoka(.subheadline))
                        .opacity(0.85)
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isOpen.toggle() }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.headline.weight(.bold))
                        .rotationEffect(.degrees(isOpen ? 0 : 180))
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isOpen ? Text("Close folder") : Text("Open folder"))
                .sensoryFeedback(.impact(weight: .light), trigger: isOpen)
            }
            HStack(alignment: .lastTextBaseline) {
                Text(verbatim: "0").font(.fredoka(.title, .bold))
                Text(verbatim: "/ 100 pts").font(.fredoka(.subheadline))
                Capsule().fill(.white.opacity(0.25)).frame(height: 6)
                    .padding(.horizontal, 12)
                Text(verbatim: "3 cards").font(.fredoka(.subheadline))
            }
            .padding(.top, 6)
        }
    }
    .padding()
    .background(Color(red: 1, green: 0.97, blue: 0.94))
}
