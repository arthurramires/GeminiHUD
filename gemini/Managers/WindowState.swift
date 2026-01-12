import Foundation
import CoreGraphics

struct WindowState: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    let isVisible: Bool
    let isFloating: Bool
}
