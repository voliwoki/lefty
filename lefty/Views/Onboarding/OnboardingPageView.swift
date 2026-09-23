import SwiftUI

struct OnboardingPageView: View {
    let symbolName: String
    let headline: String
    let bodyText: String
    let primaryTitle: String
    var secondaryTitle: String? = nil
    let onPrimary: () -> Void
    var onSecondary: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: AppSpacing.lg)

            illustration
                .frame(maxWidth: .infinity)
                .padding(.bottom, AppSpacing.xl)

            Text(headline)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Text(bodyText)
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.top, AppSpacing.md)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: AppSpacing.xl)

            LeftyActionBar(
                primaryTitle: primaryTitle,
                primaryAction: onPrimary,
                secondaryTitle: secondaryTitle,
                secondaryAction: onSecondary
            )
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(AppColors.background)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(AppColors.chipPurpleBg)
                .frame(width: 160, height: 160)

            Image(systemName: symbolName)
                .font(.system(size: 64, weight: .medium))
                .foregroundStyle(AppColors.brandPurple)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
        .frame(height: 180)
        .accessibilityHidden(true)
    }
}

#Preview {
    OnboardingPageView(
        symbolName: "globe.americas.fill",
        headline: "The world was built for the other hand.",
        bodyText: "Scissors, notebooks, knots — most how-tos assume a right hand.",
        primaryTitle: "That's me",
        secondaryTitle: "Skip",
        onPrimary: {},
        onSecondary: {}
    )
}
