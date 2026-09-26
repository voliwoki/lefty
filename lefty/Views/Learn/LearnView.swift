import SwiftUI

struct LearnView: View {
    @State private var searchText = ""
    @AppStorage("recentGuide.id") private var recentGuideID: String = ""
    @AppStorage("recentGuide.stepIndex") private var recentGuideStepIndex: Int = 0

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var searchResults: [GuideDocument] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return [] }
        return LearnContentLoader.guides.filter {
            $0.title.lowercased().contains(query) || $0.summary.lowercased().contains(query)
        }
    }

    private var sortedCategories: [LearnCategory] {
        LearnCategory.allCases.sorted { tipCount(for: $0) > tipCount(for: $1) }
    }

    private var heroCategory: LearnCategory { sortedCategories[0] }
    private var gridCategories: [LearnCategory] { Array(sortedCategories.dropFirst()) }

    private var continueGuide: GuideDocument? {
        guard !recentGuideID.isEmpty,
              let guide = LearnContentLoader.guides.first(where: { $0.id == recentGuideID }),
              recentGuideStepIndex < guide.steps.count - 1
        else { return nil }
        return guide
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Learn")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColors.primaryText)

                    searchField

                    if isSearching {
                        searchResultsList
                    } else {
                        heroCard(heroCategory)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                            ForEach(gridCategories) { category in
                                gridCard(category)
                            }
                        }

                        if let continueGuide {
                            continueSection(continueGuide)
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .toolbar(.hidden)
            .navigationDestination(for: LearnCategory.self) { category in
                LearnCategoryDetailView(category: category)
            }
            .navigationDestination(for: String.self) { guideId in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == guideId }) {
                    GuideDetailView(guide: guide)
                }
            }
            .navigationDestination(for: ContinueGuideTarget.self) { target in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == target.guideID }) {
                    GuideDetailView(guide: guide, initialStepIndex: target.stepIndex)
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryText)
            TextField("Search \(LearnContentLoader.guides.count) lefty tips", text: $searchText)
                .font(AppFont.body)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 44)
        .background(AppColors.surface)
        .clipShape(Capsule())
    }

    private var searchResultsList: some View {
        LazyVStack(spacing: AppSpacing.md) {
            if searchResults.isEmpty {
                Text("No tips found for \"\(searchText)\"")
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.top, AppSpacing.xl)
            } else {
                ForEach(searchResults) { guide in
                    NavigationLink(value: guide.id) {
                        GuideRow(guide: guide)
                    }
                    .buttonStyle(.pressScale)
                }
            }
        }
    }

    private func heroCard(_ category: LearnCategory) -> some View {
        NavigationLink(value: category) {
            HStack(spacing: AppSpacing.md) {
                categoryIcon(category, size: 56, iconSize: 22)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(category.rawValue)
                        .font(AppFont.headline)
                        .foregroundStyle(category.tone.foreground)
                    Text("\(tipCount(for: category)) tips")
                        .font(AppFont.caption)
                        .foregroundStyle(category.tone.foreground.opacity(0.85))
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category.tone.foreground)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(category.tone.background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.pressScale)
    }

    private func gridCard(_ category: LearnCategory) -> some View {
        NavigationLink(value: category) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                categoryIcon(category, size: 44, iconSize: 18)
                Text(category.rawValue)
                    .font(AppFont.headline)
                    .foregroundStyle(category.tone.foreground)
                Text("\(tipCount(for: category)) tips")
                    .font(AppFont.caption)
                    .foregroundStyle(category.tone.foreground.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(category.tone.background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        }
        .buttonStyle(.pressScale)
    }

    private func categoryIcon(_ category: LearnCategory, size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: size, height: size)
            Image(systemName: category.icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(category.tone.foreground)
        }
    }

    private func continueSection(_ guide: GuideDocument) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("PICK UP WHERE YOU LEFT OFF")
                .font(AppFont.captionEmphasized)
                .tracking(1)
                .foregroundStyle(AppColors.secondaryText)

            NavigationLink(value: ContinueGuideTarget(guideID: guide.id, stepIndex: recentGuideStepIndex)) {
                HStack(spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(guide.title)
                            .font(AppFont.headline)
                            .foregroundStyle(AppColors.primaryText)
                        HStack(spacing: AppSpacing.sm) {
                            ProgressView(value: Double(recentGuideStepIndex + 1), total: Double(guide.steps.count))
                                .tint(AppColors.accent)
                            Text("Step \(recentGuideStepIndex + 1) of \(guide.steps.count)")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColors.secondaryText)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    Spacer(minLength: AppSpacing.sm)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(AppColors.accent)
                        .clipShape(Circle())
                }
                .leftyCard()
            }
            .buttonStyle(.pressScale)
        }
    }

    private func tipCount(for category: LearnCategory) -> Int {
        LearnContentLoader.guides.filter { $0.category == category }.count
    }
}

private struct ContinueGuideTarget: Hashable {
    let guideID: String
    let stepIndex: Int
}

#Preview {
    LearnView()
}
