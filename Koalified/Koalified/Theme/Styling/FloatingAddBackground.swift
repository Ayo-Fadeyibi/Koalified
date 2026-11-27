import SwiftUI

public struct FloatingAddBackground: ViewModifier {
    private let usesGlass: Bool

    public init(usesGlass: Bool) {
        self.usesGlass = usesGlass
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *), usesGlass {
            content.glassEffect(.regular.tint(Color.mintFill).interactive(), in: Circle())
        } else {
            content.neoBrutalist(backgroundColor: Color.mintFill, cornerRadius: Layout.fabSize / 2)
        }
    }
}
