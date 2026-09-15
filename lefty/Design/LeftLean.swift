import SwiftUI

extension View {
    func leftLean(_ degrees: Double = 10) -> some View {
        let radians = degrees * .pi / 180
        return transformEffect(CGAffineTransform(a: 1, b: 0, c: CGFloat(tan(radians)), d: 1, tx: 0, ty: 0))
    }
}
