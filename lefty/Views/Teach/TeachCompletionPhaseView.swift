import SwiftUI

struct TeachCompletionPhaseView: View {
    let isSaved: Bool
    let onSave: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.chipGreenFg)
                .accessibilityHidden(true)
            Text("Nice! You've got a left-handed guide.")
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
            Text("Save it to My Lefty so you can come back to it anytime.")
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Spacer()
            LeftyActionBar(
                primaryTitle: isSaved ? "Saved" : "Save to My Lefty",
                primaryIcon: isSaved ? "checkmark" : "square.and.arrow.down",
                isPrimaryEnabled: !isSaved,
                primaryAction: onSave,
                secondaryTitle: "Done",
                secondaryAction: onDone
            )
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppColors.background)
    }
}
