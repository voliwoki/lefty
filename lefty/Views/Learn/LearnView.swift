import SwiftUI

struct LearnView: View {
    @State private var selectedCategory: LearnCategory?

    private var filteredGuides: [GuideDocument] {
        guard let selectedCategory else { return LearnContentLoader.guides }
        return LearnContentLoader.guides.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    categoryRow
                    guideList
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .navigationTitle("Learn")
            .navigationDestination(for: String.self) { guideId in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == guideId }) {
                    GuideDetailView(guide: guide)
                }
            }
        }
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                categoryChip(nil, title: "All")
                ForEach(LearnCategory.allCases) { category in
                    categoryChip(category, title: category.rawValue)
                }
            }
        }
    }

    private func categoryChip(_ category: LearnCategory?, title: String) -> some View {
        Button {
            selectedCategory = category
        } label: {
            LeftyChip(title: title, tone: category?.tone ?? .purple, isSelected: selectedCategory == category)
        }
        .buttonStyle(.plain)
    }

    private var guideList: some View {
        LazyVStack(spacing: AppSpacing.md) {
            ForEach(filteredGuides) { guide in
                NavigationLink(value: guide.id) {
                    GuideRow(guide: guide)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    LearnView()
}
