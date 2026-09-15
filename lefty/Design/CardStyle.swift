import SwiftUI

extension View {
    func leftyCard(padding: CGFloat = AppSpacing.lg) -> some View {
        self
            .padding(padding)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}
