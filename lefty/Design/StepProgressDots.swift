import SwiftUI

struct StepProgressDots: View {
    let total: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? AppColors.accent : AppColors.separator)
                    .frame(width: index == currentIndex ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    StepProgressDots(total: 5, currentIndex: 1)
}
