import SwiftUI

struct TeachDeclinedPhaseView: View {
    let guide: GeneratedGuide
    let onTryAgain: () -> Void

    private var isUnsafe: Bool { guide.confidence == .unsafe }

    private var icon: String {
        isUnsafe ? "exclamationmark.triangle.fill" : "questionmark.circle.fill"
    }

    private var tone: ChipTone {
        isUnsafe ? .pink : .yellow
    }

    private var title: String {
        isUnsafe ? "Let's not do this one alone" : "Need a clearer look"
    }

    private var message: String {
        if isUnsafe {
            return guide.safetyNote ?? "This looks like it could be risky to do without an adult or a professional's help. Try something else, or ask a grown-up to help you find left-handed instructions for this."
        }
        return guide.clarifyingQuestion ?? "Lefty couldn't quite tell what's needed from that photo or description. Try again with a clearer photo, or add a bit more detail."
    }

    private var buttonTitle: String {
        isUnsafe ? "Back" : "Try Again"
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            LeftyIconBadge(systemImage: icon, tone: tone, size: 64)
            Text(title)
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            Text(message)
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Spacer()
            LeftyActionBar(
                primaryTitle: buttonTitle,
                primaryAction: onTryAgain
            )
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppColors.background)
    }
}

#Preview {
    TeachDeclinedPhaseView(
        guide: GeneratedGuide(
            title: "Unclear",
            estimatedMinutes: nil,
            summary: "",
            whatChanges: "",
            whatStaysSame: "",
            confidence: .needMoreInfo,
            clarifyingQuestion: "Could you take a clearer photo of the full instructions?",
            steps: [],
            safetyNote: nil
        ),
        onTryAgain: {}
    )
}
