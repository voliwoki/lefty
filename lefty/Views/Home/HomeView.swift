import SwiftUI

struct HomeView: View {
    let onTeachTapped: () -> Void
    let onBrowseLearnTapped: () -> Void

    @State private var tip = LeftyTipPool.tips.randomElement() ?? LeftyTipPool.tips[0]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    heroCard
                    popularGuidesSection
                    tipCard
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .toolbar(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "hand.wave.fill")
                .scaleEffect(x: -1, y: 1)
                .foregroundStyle(AppColors.brandPurple)
                .accessibilityHidden(true)
            Text("Lefty")
                .font(AppFont.logo(size: 36))
                .foregroundStyle(AppColors.brandPurple)
                .leftLean()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lefty")
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("What do you want to learn?")
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
            Text("Show Lefty a photo, an upload, or just type it in.")
                .font(AppFont.subheadline)
                .foregroundStyle(AppColors.secondaryText)
            LeftyActionBar(
                primaryTitle: "Teach me left-handed",
                primaryIcon: "hand.point.up.left.fill",
                primaryAction: onTeachTapped
            )
        }
        .leftyCard()
    }

    private var popularGuidesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Popular Lefty Guides")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(PopularGuideStub.samples) { guide in
                        guideCard(guide)
                    }
                }
            }
        }
    }

    private func guideCard(_ guide: PopularGuideStub) -> some View {
        Button(action: onBrowseLearnTapped) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                LeftyIconBadge(systemImage: guide.icon, tone: guide.tone)
                Text(guide.title)
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(width: 140, alignment: .leading)
            .padding(AppSpacing.md)
            .frame(minHeight: 44)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .buttonStyle(.plain)
    }

    private var tipCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: "lightbulb.fill", tone: .yellow)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Quick Lefty Tip")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(tip)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .leftyCard()
    }
}

#Preview {
    HomeView(onTeachTapped: {}, onBrowseLearnTapped: {})
}
