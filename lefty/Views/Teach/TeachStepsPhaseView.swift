import SwiftUI

struct TeachStepsPhaseView: View {
    let guide: GeneratedGuide
    let onComplete: () -> Void

    @State private var stepIndex = 0
    @State private var goingForward = true

    private var currentStep: GuideStep { guide.steps[stepIndex] }
    private var isFirstStep: Bool { stepIndex == 0 }
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }
    private var primaryButtonTitle: String { isLastStep ? "Done" : "Next step" }
    private var primaryTrailingIcon: String? { isLastStep ? nil : "arrow.right" }
    private var secondaryButtonTitle: String? { isFirstStep ? nil : "Back" }
    private var estimatedMinutes: Int { guide.estimatedMinutes ?? max(1, guide.steps.count) }

    private var stepBackAction: (() -> Void)? {
        if isFirstStep {
            return nil
        }
        return goBack
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                        .font(AppFont.subheadlineEmphasized)
                        .foregroundStyle(AppColors.secondaryText)
                    Spacer()
                    Text("about \(estimatedMinutes) min")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(.top, AppSpacing.lg)

                StepProgressBar(total: guide.steps.count, currentIndex: stepIndex)

                Text(currentStep.instruction)
                    .font(AppFont.title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(stepIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                    ))
                    .padding(.vertical, AppSpacing.xxl)
                    .leftyCard(padding: AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: primaryButtonTitle,
                primaryTrailingIcon: primaryTrailingIcon,
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
