import SwiftUI

struct TeachOverviewPhaseView: View {
    let guide: GeneratedGuide
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(guide.title)
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.primaryText)
                    if let minutes = guide.estimatedMinutes {
                        Text("About \(minutes) minutes")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                Text(guide.summary)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.secondaryText)

                if let safetyNote = guide.safetyNote {
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.chipPinkFg)
                        Text(safetyNote)
                            .font(AppFont.subheadline)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.chipPinkBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }

                infoRow(title: "What changes", text: guide.whatChanges, tone: .yellow)
                infoRow(title: "What stays the same", text: guide.whatStaysSame, tone: .green)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: "Start",
                primaryIcon: "play.fill",
                primaryAction: onStart
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
    }

    private func infoRow(title: String, text: String, tone: ChipTone) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: "circle.fill", tone: tone)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(text)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .leftyCard()
    }
}
