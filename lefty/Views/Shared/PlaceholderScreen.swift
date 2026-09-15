import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                Spacer()
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.accent)
                    .accessibilityHidden(true)
                Text(title)
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
                Text(message)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(AppColors.background)
            .navigationTitle(title)
        }
    }
}
