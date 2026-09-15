import SwiftUI

struct TeachStepsPhaseView: View {
    let guide: GeneratedGuide
    let onComplete: () -> Void

    @State private var stepIndex = 0

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
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text(currentStep.instruction)
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
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
            stepIndex += 1
        }
    }

    private func goBack() {
        stepIndex = max(0, stepIndex - 1)
    }
}
