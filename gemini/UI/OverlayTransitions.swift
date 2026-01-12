import SwiftUI

extension AnyTransition {

    static var clipboardOverlay: AnyTransition {
        let insertion = AnyTransition
            .move(edge: .bottom)
            .combined(with: .opacity)
            .combined(with: .scale(scale: 0.96, anchor: .bottom))

        let removal = AnyTransition
            .move(edge: .bottom)
            .combined(with: .opacity)

        return .asymmetric(
            insertion: insertion,
            removal: removal
        )
    }
}
