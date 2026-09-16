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
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LearnCategoryDetailView(category: .writing)
    }
}
