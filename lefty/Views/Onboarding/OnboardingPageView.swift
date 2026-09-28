import SwiftUI

struct OnboardingPageView: View {
    let illustrationName: String
    let headline: String
    let bodyText: String
    let primaryTitle: String
    var secondaryTitle: String? = nil
    let onPrimary: () -> Void
    var onSecondary: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: AppSpacing.lg)

            Image(illustrationName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .frame(maxWidth: .infinity)
                .padding(.bottom, AppSpacing.xl)
                .accessibilityHidden(true)

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
}

#Preview {
    OnboardingPageView(
        illustrationName: "OnboardingSignpost",
        headline: "The world was built for the other hand.",
        bodyText: "Scissors, notebooks, knots — most how-tos assume a right hand.",
        primaryTitle: "That's me",
        onPrimary: {}
    )
}
