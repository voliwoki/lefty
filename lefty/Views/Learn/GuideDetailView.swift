import SwiftUI
import SwiftData

struct GuideDetailView: View {
    let guide: GuideDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteGuide]
    @State private var stepIndex = 0
    @State private var goingForward = true

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
            VStack(spacing: AppSpacing.xl) {
                StepProgressDots(total: guide.steps.count, currentIndex: stepIndex)
                    .padding(.top, AppSpacing.xxl)

                VStack(spacing: AppSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppColors.chipPurpleBg)
                            .frame(width: 56, height: 56)
                        Text("\(stepIndex + 1)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.chipPurpleFg)
                    }
                    .accessibilityHidden(true)

                    Text(currentStep.instruction)
                        .font(AppFont.largeTitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColors.primaryText)
                }
                .id(stepIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                ))
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
                .leftyCard(padding: AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
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
        .toolbar(.hidden, for: .tabBar)
    }

    private func advance() {
        if isLastStep {
            dismiss()
        } else {
            goingForward = true
            withAnimation(.easeInOut(duration: 0.25)) {
                stepIndex += 1
            }
        }
    }

    private func goBack() {
        goingForward = false
        withAnimation(.easeInOut(duration: 0.25)) {
            stepIndex = max(0, stepIndex - 1)
        }
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
