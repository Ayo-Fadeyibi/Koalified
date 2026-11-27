//
//  FolderShape.swift
//  Koalified
//
//  Created by Ayooluwa Fadeyibi on 26/11/2026.
//

import SwiftUI

struct FolderFrontShape: Shape {
    var corner: CGFloat = 24      // rounded corners
    var raise: CGFloat = 40       // how much higher the middle sits
    var shoulder: CGFloat = 36    // width of each curved slope
    var inset: CGFloat = 0.1      // share of the width each lower side takes before the slope starts
    var bottomCorner: CGFloat = Layout.radiusCard   // matches the back card's corners

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let top = rect.minY + raise          // top edge at the sides
        let midL = rect.minX + rect.width * inset   // raised section starts
        let midR = rect.maxX - rect.width * inset   // raised section ends
        
//        rect.minX   = 0
//        rect.maxX  =  345
//        rect.minY =   0
//        rect.maxY  =  160
//        corner  =  24
//        raise   = 40
//        shoulder   = 36
//        top  =  40 (minY + raise)
//        midL  =  69 (345 × 0.2)
//        midR  =  276 (345 − 69)

        //This is the starting point
        p.move(to: CGPoint(x: rect.minX, y: top + corner))
        // TODO 1: rounded top-left corner, ending at (rect.minX + corner, top)
        p.addQuadCurve(
            to: CGPoint(x: rect.minX + corner, y: top),
            control: CGPoint(x: rect.minX, y: top)
        )
        // TODO 2: straight line along the lower edge to (midL, top)
        p.addLine(to: CGPoint(x: midL, y: top))
        // TODO 3: curve up to (midL + shoulder, rect.minY)  (addCurve with two controls)
        p.addCurve(
            to: CGPoint(x: midL + shoulder, y: rect.minY),
            control1: CGPoint(x: midL + shoulder / 2, y: top),
            control2: CGPoint(x: midL + shoulder / 2, y: rect.minY)
        )
        // TODO 4: straight line along the raised middle to (midR - shoulder, rect.minY)
        p.addLine(to: CGPoint(x: midR - shoulder, y: rect.minY))
        // TODO 5: curve back down to (midR, top)
        p.addCurve(
            to: CGPoint(x: midR, y: top),
            control1: CGPoint(x: midR - shoulder / 2, y: rect.minY),
            control2: CGPoint(x: midR - shoulder / 2, y: top)
        )
        // TODO 6: line to the top-right corner, then round it
        p.addLine(to: CGPoint(x: rect.maxX - corner, y: top))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: top + corner),
            control: CGPoint(x: rect.maxX, y: top)
        )
        // TODO 7: down the right side, along the bottom, close the path
        // The bottom corners are rounded too, so the front matches the back card's rounded corners.
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomCorner))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomCorner, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        p.addLine(to: CGPoint(x: rect.minX + bottomCorner, y: rect.maxY))
        p.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomCorner),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        p.closeSubpath()
        return p
    }
}


#Preview {
    FolderFrontShape()
        .fill(Color(red: 0.12, green: 0.34, blue: 0.26))
        .frame(width: 345, height: 160)
        .padding()
}
