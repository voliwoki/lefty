import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                ForEach(LearnCategory.allCases) { category in
                    NavigationLink(value: category) {
                        categoryRow(category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Learn")
            .navigationDestination(for: LearnCategory.self) { category in
                LearnCategoryDetailView(category: category)
            }
            .navigationDestination(for: String.self) { guideId in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == guideId }) {
                    GuideDetailView(guide: guide)
                }
            }
        }
    }

    private func categoryRow(_ category: LearnCategory) -> some View {
        HStack(spacing: AppSpacing.md) {
            LeftyIconBadge(systemImage: category.icon, tone: category.tone, size: 56)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(category.rawValue)
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
                Text("\(tipCount(for: category)) tips")
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .leftyCard()
    }

    private func tipCount(for category: LearnCategory) -> Int {
        LearnContentLoader.guides.filter { $0.category == category }.count
    }
}

#Preview {
    LearnView()
}
