import SwiftUI

private enum OnboardingStep: Equatable {
    case identity
    case content(Int)
    case paywall
}

struct OnboardingFlowView: View {
    @Environment(SubscriptionService.self) private var subscription
    @Binding var hasCompletedOnboarding: Bool

    @State private var audience: OnboardingAudience?
    @State private var step: OnboardingStep = .identity
    @State private var contentIndex = 0

    private var contentPages: [OnboardingPageContent] {
        guard let audience else { return [] }
        return OnboardingCopy.contentPages(for: audience)
    }

    private var progressTotal: Int {
        // Identity + content pages (paywall has its own chrome)
        1 + max(contentPages.count, 4)
    }

    private var progressIndex: Int {
        switch step {
        case .identity: 0
        case .content(let index): 1 + index
        case .paywall: progressTotal - 1
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            switch step {
            case .identity:
                identityStep
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .content:
                if let page = contentPages[safe: contentIndex] {
                    contentStep(page: page)
                        .id(page.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            case .paywall:
                PaywallSheet(onFinished: completeOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    private var identityStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            topChrome(showSkip: true)

            Spacer(minLength: AppSpacing.lg)

            HandDrawnHandIcon(size: 56)
                .padding(.bottom, AppSpacing.md)

            Text(OnboardingCopy.identityHeadline)
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColors.primaryText)

            Text(OnboardingCopy.identityBody)
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .padding(.top, AppSpacing.md)

            VStack(spacing: AppSpacing.md) {
                ForEach(OnboardingAudience.allCases) { option in
                    audienceCard(option)
                }
            }
            .padding(.top, AppSpacing.xl)

            Spacer(minLength: AppSpacing.xl)

            LeftyActionBar(
                primaryTitle: OnboardingCopy.identityCTA,
                isPrimaryEnabled: audience != nil,
                primaryAction: advanceFromIdentity
            )
            .padding(.bottom, AppSpacing.lg)
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    private func contentStep(page: OnboardingPageContent) -> some View {
        VStack(spacing: 0) {
            topChrome(showSkip: true)
            OnboardingPageView(
                symbolName: page.symbolName,
                headline: page.headline,
                bodyText: page.body,
                primaryTitle: page.primaryCTA,
                onPrimary: advanceFromContent
            )
        }
    }

    private func topChrome(showSkip: Bool) -> some View {
        HStack {
            StepProgressDots(total: progressTotal, currentIndex: min(progressIndex, progressTotal - 1))
            Spacer()
            if showSkip {
                Button(OnboardingCopy.skipTitle) {
                    completeOnboarding()
                }
                .font(AppFont.subheadlineEmphasized)
                .foregroundStyle(AppColors.secondaryText)
                .frame(minWidth: 44, minHeight: 44)
                .buttonStyle(.pressScale)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    private func audienceCard(_ option: OnboardingAudience) -> some View {
        let isSelected = audience == option
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                audience = option
            }
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.brandPurple)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? AppColors.chipPinkBg : AppColors.chipPurpleBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(option.title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Text(option.subtitle)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AppColors.accent : AppColors.separator)
                    .frame(width: 44, height: 44)
            }
            .padding(AppSpacing.md)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .strokeBorder(isSelected ? AppColors.accent : AppColors.separator, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.pressScale)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func advanceFromIdentity() {
        guard audience != nil else { return }
        contentIndex = 0
        withAnimation {
            step = .content(0)
        }
    }

    private func advanceFromContent() {
        let next = contentIndex + 1
        if next < contentPages.count {
            contentIndex = next
            withAnimation {
                step = .content(next)
            }
        } else if subscription.isLeftyPlusActive {
            completeOnboarding()
        } else {
            withAnimation {
                step = .paywall
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    @Previewable @State var done = false
    OnboardingFlowView(hasCompletedOnboarding: $done)
        .environment(SubscriptionService())
}
