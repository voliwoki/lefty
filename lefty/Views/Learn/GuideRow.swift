import SwiftUI

struct GuideRow: View {
    let guide: GuideDocument

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: guide.icon, tone: guide.category.tone)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(guide.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(guide.summary)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .leftyCard()
    }
}
