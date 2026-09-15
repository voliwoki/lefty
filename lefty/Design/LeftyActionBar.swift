import SwiftUI

struct LeftyActionBar: View {
    let primaryTitle: String
    var primaryIcon: String? = nil
    var isPrimaryEnabled: Bool = true
    let primaryAction: () -> Void
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button(action: primaryAction) {
                HStack(spacing: AppSpacing.sm) {
                    if let primaryIcon {
                        Image(systemName: primaryIcon)
                    }
                    Text(primaryTitle)
                        .font(AppFont.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            .foregroundStyle(.white)
            .controlSize(.large)
            .disabled(!isPrimaryEnabled)

            if let secondaryTitle, let secondaryAction {
                Button(secondaryTitle, action: secondaryAction)
                    .buttonStyle(.bordered)
                    .tint(AppColors.secondaryText)
                    .controlSize(.large)
            }
        }
    }
}

struct LeftyIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColors.primaryText)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    VStack {
        Spacer()
        LeftyActionBar(
            primaryTitle: "Teach me left-handed",
            primaryIcon: "hand.point.up.left.fill",
            primaryAction: {},
            secondaryTitle: "Back",
            secondaryAction: {}
        )
        .padding(AppSpacing.lg)
    }
    .background(AppColors.background)
}
