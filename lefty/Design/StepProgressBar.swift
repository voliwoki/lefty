import SwiftUI

struct StepProgressBar: View {
    let total: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? AppColors.accent : AppColors.separator)
                    .frame(height: 6)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    StepProgressBar(total: 4, currentIndex: 0)
        .padding()
        .background(AppColors.background)
}
