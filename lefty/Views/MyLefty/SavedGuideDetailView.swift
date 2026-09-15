import SwiftUI

struct SavedGuideDetailView: View {
    let guide: SavedGuide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                ForEach(guide.steps) { step in
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Step \(step.number)")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.secondaryText)
                        Text(step.instruction)
                            .font(AppFont.body)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .leftyCard()
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
