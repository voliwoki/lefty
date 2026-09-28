import SwiftUI

struct TeachOverviewPhaseView: View {
    let guide: GeneratedGuide
    let onStart: () -> Void

    private var minutes: Int {
        guide.estimatedMinutes ?? max(1, guide.steps.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(guide.title)
                        .font(AppFont.title)
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("About \(minutes) minutes · \(guide.steps.count) steps")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }

                if guide.confidence == .uncertain {
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(AppColors.chipYellowFg)
                        Text("Lefty isn't fully sure about this one — double check as you go.")
                            .font(AppFont.subheadline)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.chipYellowBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }

                if let safetyNote = guide.safetyNote {
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.chipPinkFg)
                        Text(safetyNote)
                            .font(AppFont.subheadline)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.chipPinkBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                }

                VStack(spacing: AppSpacing.md) {
                    infoCard(
                        title: String(localized: "What changes"),
                        text: guide.whatChanges,
                        tone: .yellow
                    )
                    infoCard(
                        title: String(localized: "What stays the same"),
                        text: guide.whatStaysSame,
                        tone: .green
                    )
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: String(localized: "Start"),
                primaryIcon: "play.fill",
                primaryAction: onStart
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
    }

    private func infoCard(title: String, text: String, tone: ChipTone) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.captionEmphasized)
                .foregroundStyle(tone.foreground)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(tone.background)
                .clipShape(Capsule())

            Text(text)
                .font(AppFont.body)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .leftyCard(padding: AppSpacing.md)
    }
}
