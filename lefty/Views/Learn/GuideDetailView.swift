import SwiftUI
import SwiftData

struct GuideDetailView: View {
    let guide: GuideDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteGuide]
    @State private var stepIndex = 0

    init(guide: GuideDocument) {
        self.guide = guide
        let guideId = guide.id
        _favorites = Query(filter: #Predicate<FavoriteGuide> { $0.guideId == guideId })
    }

    private var isFavorited: Bool { !favorites.isEmpty }
    private var currentStep: GuideStepDocument { guide.steps[stepIndex] }
    private var isFirstStep: Bool { stepIndex == 0 }
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }
    private var favoriteIconName: String { isFavorited ? "heart.fill" : "heart" }
    private var favoriteAccessibilityLabel: String { isFavorited ? "Remove from favorites" : "Add to favorites" }
    private var primaryButtonTitle: String { isLastStep ? "Done" : "Next" }
    private var secondaryButtonTitle: String? { isFirstStep ? nil : "Back" }

    private var stepBackAction: (() -> Void)? {
        if isFirstStep {
            return nil
        }
        return goBack
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text(currentStep.instruction)
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: primaryButtonTitle,
                primaryAction: advance,
                secondaryTitle: secondaryButtonTitle,
                secondaryAction: stepBackAction
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                LeftyIconButton(
                    systemImage: favoriteIconName,
                    accessibilityLabel: favoriteAccessibilityLabel
                ) {
                    toggleFavorite()
                }
            }
        }
    }

    private func advance() {
        if isLastStep {
            dismiss()
        } else {
            stepIndex += 1
        }
    }

    private func goBack() {
        stepIndex = max(0, stepIndex - 1)
    }

    private func toggleFavorite() {
        if let existing = favorites.first {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteGuide(guideId: guide.id))
        }
    }
}

#Preview {
    NavigationStack {
        GuideDetailView(guide: LearnContentLoader.guides[0])
    }
    .modelContainer(for: FavoriteGuide.self, inMemory: true)
}
