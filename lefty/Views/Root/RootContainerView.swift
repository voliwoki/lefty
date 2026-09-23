import SwiftUI

struct RootContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    @State private var logoVisible = false

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                TabRootView()
            } else if !showSplash {
                OnboardingFlowView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            }

            if showSplash {
                SplashView(logoVisible: logoVisible)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                logoVisible = true
            }
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.easeInOut(duration: 0.35)) {
                showSplash = false
            }
        }
    }
}

private struct SplashView: View {
    let logoVisible: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            HandDrawnHandIcon(size: 40)
            Text("lefty")
                .font(AppFont.logo(size: 48))
                .foregroundStyle(AppColors.brandPurple)
                .leftLean()
        }
        .scaleEffect(logoVisible ? 1 : 0.6)
        .opacity(logoVisible ? 1 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

#Preview("First launch") {
    RootContainerView()
        .environment(SubscriptionService())
}

#Preview("Returning") {
    RootContainerView()
        .environment(SubscriptionService())
        .defaultAppStorage({
            let defaults = UserDefaults(suiteName: "preview.returning")!
            defaults.set(true, forKey: "hasCompletedOnboarding")
            return defaults
        }())
}
