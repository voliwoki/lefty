import SwiftUI

struct LearnCategoryDetailView: View {
    let category: LearnCategory

    private var guides: [GuideDocument] {
        LearnContentLoader.guides.filter { $0.category == category }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(guides) { guide in
                    NavigationLink(value: guide.id) {
                        GuideRow(guide: guide)
                    }
                    .buttonStyle(.pressScale)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(category.rawValue)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Text("\(guides.count) guide\(guides.count == 1 ? "" : "s")")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LearnCategoryDetailView(category: .writing)
    }
}
