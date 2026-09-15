import SwiftUI
import SwiftData

struct MyLeftyView: View {
    @Query(sort: \FavoriteGuide.createdAt, order: .reverse) private var favorites: [FavoriteGuide]
    @Query(sort: \SavedGuide.createdAt, order: .reverse) private var savedGuides: [SavedGuide]

    private var favoritedGuides: [GuideDocument] {
        favorites.compactMap { favorite in
            LearnContentLoader.guides.first { $0.id == favorite.guideId }
        }
    }

    private var hasNothingSaved: Bool {
        favoritedGuides.isEmpty && savedGuides.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    statsRow
                    if hasNothingSaved {
                        emptyState
                    } else {
                        if !savedGuides.isEmpty {
                            savedGuidesSection
                        }
                        if !favoritedGuides.isEmpty {
                            favoritesSection
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .navigationTitle("My Lefty")
            .navigationDestination(for: String.self) { guideId in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == guideId }) {
                    GuideDetailView(guide: guide)
                }
            }
            .navigationDestination(for: SavedGuide.self) { guide in
                SavedGuideDetailView(guide: guide)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            statCard(icon: "square.and.arrow.down.fill", tone: .purple, count: savedGuides.count, label: "saved")
            statCard(icon: "heart.fill", tone: .pink, count: favoritedGuides.count, label: "favorited")
        }
    }

    private func statCard(icon: String, tone: ChipTone, count: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            LeftyIconBadge(systemImage: icon, tone: tone)
            Text("\(count)")
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .leftyCard()
    }

    private var savedGuidesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Saved from Teach")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(savedGuides) { guide in
                    NavigationLink(value: guide) {
                        savedGuideRow(guide)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func savedGuideRow(_ guide: SavedGuide) -> some View {
        HStack(spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: "square.and.arrow.down.fill", tone: .purple)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(guide.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text("\(guide.steps.count) steps")
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .leftyCard()
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Favorites")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(favoritedGuides) { guide in
                    NavigationLink(value: guide.id) {
                        GuideRow(guide: guide)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "heart")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.accent)
                .accessibilityHidden(true)
            Text("Nothing here yet")
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
            Text("Guides you save from Teach Me Left-Handed or favorite in Learn will show up here.")
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
    }
}

#Preview {
    MyLeftyView()
        .modelContainer(for: [FavoriteGuide.self, SavedGuide.self], inMemory: true)
}
