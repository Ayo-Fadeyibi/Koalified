//
//  TicketPiece.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 23/11/2026.
//

import SwiftUI

extension View {
    /// Gives a section of the card its own surface and border so it can split off along the seam.
    func ticketPiece(seam: TicketPiece.Seam, tear: CGFloat) -> some View {
        background(TicketPiece(seam: seam, tear: tear, cornerRadius: Layout.radiusCard).fill(Color.cardSurface))
            .overlay(
                TicketPiece(seam: seam, tear: tear, closed: false, cornerRadius: Layout.radiusCard)
                    .strokeBorder(Color.inkBorder, lineWidth: Layout.borderWidth)
            )
    }
}

/// One piece of a ticket-style card. The `seam` edge is where the card splits at the dashed line,
/// and `tear` (0...1) turns that edge from straight into a jagged rip. Both pieces use the same
/// tooth pattern so their torn edges line up.
nonisolated struct TicketPiece: InsettableShape {
    enum Seam { case none, top, bottom }

    var seam: Seam
    var tear: CGFloat
    /// The fill is closed; the border leaves out the seam until it's torn so it doesn't cover the dashed line.
    var closed = true
    var cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    var animatableData: CGFloat {
        get { tear }
        set { tear = newValue }
    }

    func inset(by amount: CGFloat) -> TicketPiece {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        var r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        // Keep the seam flush with the neighbouring piece.
        switch seam {
        case .none: break
        case .top:
            r.origin.y = rect.minY
            r.size.height += insetAmount
        case .bottom:
            r.size.height += insetAmount
        }
        let radius = max(0, min(cornerRadius - insetAmount, r.width / 2, r.height / 2))

        if seam == .none {
            return Path(roundedRect: r, cornerRadius: radius)
        }

        var path = Path()
        switch seam {
        case .none:
            break
        case .bottom:
            // Left side up, across the rounded top, down the right side.
            path.move(to: CGPoint(x: r.minX, y: r.maxY))
            path.addArc(tangent1End: CGPoint(x: r.minX, y: r.minY), tangent2End: CGPoint(x: r.maxX, y: r.minY), radius: radius)
            path.addArc(tangent1End: CGPoint(x: r.maxX, y: r.minY), tangent2End: CGPoint(x: r.maxX, y: r.maxY), radius: radius)
            path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        case .top:
            // Right side down, across the rounded bottom, up the left side.
            path.move(to: CGPoint(x: r.maxX, y: r.minY))
            path.addArc(tangent1End: CGPoint(x: r.maxX, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.maxY), radius: radius)
            path.addArc(tangent1End: CGPoint(x: r.minX, y: r.maxY), tangent2End: CGPoint(x: r.minX, y: r.minY), radius: radius)
            path.addLine(to: CGPoint(x: r.minX, y: r.minY))
        }

        if closed || tear > 0 {
            addSeam(to: &path, in: rect, clampedTo: r)
        }
        if closed {
            path.closeSubpath()
        }
        return path
    }

    /// Zigzag across the seam. Tooth positions come from the un-inset rect so the fill, the border
    /// and the matching piece all share the same teeth.
    private func addSeam(to path: inout Path, in rect: CGRect, clampedTo r: CGRect) {
        let tearDepth: CGFloat = 8 * tear
        let y = seam == .bottom ? r.maxY : r.minY
        let teeth = max(2, Int(rect.width / 10))
        let indices: [Int] = seam == .bottom ? Array((0...teeth).reversed()) : Array(0...teeth)
        for tooth in indices {
            let x = min(max(rect.minX + rect.width * CGFloat(tooth) / CGFloat(teeth), r.minX), r.maxX)
            let isEnd = tooth == 0 || tooth == teeth
            let offset = isEnd ? 0 : (tooth.isMultiple(of: 2) ? -tearDepth / 2 : tearDepth / 2)
            path.addLine(to: CGPoint(x: x, y: y + offset))
        }
    }
}
