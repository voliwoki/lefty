import SwiftUI

struct TeachStepsPhaseView: View {
    let guide: GeneratedGuide
    let onComplete: () -> Void

    @State private var stepIndex = 0
    @State private var goingForward = true

    private var currentStep: GuideStep { guide.steps[stepIndex] }
    private var isFirstStep: Bool { stepIndex == 0 }
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }
    private var primaryButtonTitle: String { isLastStep ? "Done" : "Next" }
    private var secondaryButtonTitle: String? { isFirstStep ? nil : "Back" }

    private var stepBackAction: (() -> Void)? {
        if isFirstStep {
            return nil
        }
        return goBack
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                StepProgressDots(total: guide.steps.count, currentIndex: stepIndex)
                    .padding(.top, AppSpacing.lg)

                VStack(spacing: AppSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppColors.chipPurpleBg)
                            .frame(width: 56, height: 56)
                        Text("\(stepIndex + 1)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.chipPurpleFg)
                    }
                    .accessibilityHidden(true)

                    Text(currentStep.instruction)
                        .font(AppFont.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColors.primaryText)
                }
                .id(stepIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
                .leftyCard(padding: AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: primaryButtonTitle,
                primaryAction: advance,
                secondaryTitle: secondaryButtonTitle,
                secondaryAction: stepBackAction
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
    }

    private func advance() {
        if isLastStep {
            onComplete()
        } else {
            goingForward = true
            withAnimation(.easeInOut(duration: 0.25)) {
                stepIndex += 1
            }
        }
    }

    private func goBack() {
        goingForward = false
        withAnimation(.easeInOut(duration: 0.25)) {
            stepIndex = max(0, stepIndex - 1)
        }
    }
}
