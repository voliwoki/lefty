import SwiftUI

/// The same hand-drawn hand illustration used on the app icon, reused as a small
/// inline mark next to the "lefty" wordmark.
struct HandDrawnHandIcon: View {
    var size: CGFloat = 28

    var body: some View {
        Image("HandWordmark")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    HandDrawnHandIcon(size: 48)
        .padding()
        .background(AppColors.background)
}
