import SwiftUI

struct LeftyIconBadge: View {
    let systemImage: String
    var tone: ChipTone = .purple
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tone.foreground)
            .frame(width: size, height: size)
            .background(tone.background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        LeftyIconBadge(systemImage: "lightbulb.fill", tone: .yellow)
        LeftyIconBadge(systemImage: "cart.fill", tone: .pink)
        LeftyIconBadge(systemImage: "person.2.fill", tone: .purple)
    }
    .padding()
    .background(AppColors.background)
}
