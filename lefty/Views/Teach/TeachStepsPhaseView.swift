import SwiftUI

struct TeachStepsPhaseView: View {
    let guide: GeneratedGuide
    @Binding var stepIndex: Int
    let onComplete: () -> Void

    @State private var goingForward = true

    private var currentStep: GuideStep { guide.steps[stepIndex] }
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                        .font(AppFont.subheadlineEmphasized)
                        .foregroundStyle(AppColors.secondaryText)

                    StepProgressBar(total: guide.steps.count, currentIndex: stepIndex)
                }

                Text(currentStep.instruction)
                    .font(AppFont.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .id(stepIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                    ))
                    .leftyCard(padding: AppSpacing.lg)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeInOut(duration: 0.25), value: stepIndex)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: isLastStep ? String(localized: "Finish") : String(localized: "Next step"),
                primaryTrailingIcon: isLastStep ? nil : "arrow.right",
                primaryAction: advance
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .onChange(of: stepIndex) { oldValue, newValue in
            goingForward = newValue >= oldValue
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
}
