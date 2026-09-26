import SwiftUI
import SwiftData

struct GuideDetailView: View {
    let guide: GuideDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteGuide]
    @State private var stepIndex: Int
    @State private var goingForward = true
    @AppStorage("recentGuide.id") private var recentGuideID: String = ""
    @AppStorage("recentGuide.stepIndex") private var recentGuideStepIndex: Int = 0

    init(guide: GuideDocument, initialStepIndex: Int = 0) {
        self.guide = guide
        _stepIndex = State(initialValue: initialStepIndex)
        let guideId = guide.id
        _favorites = Query(filter: #Predicate<FavoriteGuide> { $0.guideId == guideId })
    }

    private var isFavorited: Bool { !favorites.isEmpty }
    private var currentStep: GuideStepDocument { guide.steps[stepIndex] }
    private var isFirstStep: Bool { stepIndex == 0 }
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }
    private var favoriteIconName: String { isFavorited ? "heart.fill" : "heart" }
    private var favoriteAccessibilityLabel: String { isFavorited ? "Remove from favorites" : "Add to favorites" }
    private var primaryButtonTitle: String { isLastStep ? "Done" : "Next step" }
    private var primaryTrailingIcon: String? { isLastStep ? nil : "arrow.right" }
    private var secondaryButtonTitle: String? { isFirstStep ? nil : "Back" }

    private var stepBackAction: (() -> Void)? {
        if isFirstStep {
            return nil
        }
        return goBack
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                        .font(AppFont.subheadlineEmphasized)
                        .foregroundStyle(AppColors.secondaryText)
                    Spacer()
                    Text("about \(guide.estimatedMinutes) min")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(.top, AppSpacing.xxl)

                StepProgressBar(total: guide.steps.count, currentIndex: stepIndex)

                Text(currentStep.instruction)
                    .font(AppFont.title)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(stepIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                    ))
                    .padding(.vertical, AppSpacing.xxl)
                    .leftyCard(padding: AppSpacing.xl)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: primaryButtonTitle,
                primaryTrailingIcon: primaryTrailingIcon,
                primaryAction: advance,
                secondaryTitle: secondaryButtonTitle,
                secondaryAction: stepBackAction
            )
            .padding(AppSpacing.lg)
            .background(AppColors.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(guide.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                LeftyIconButton(
                    systemImage: favoriteIconName,
                    accessibilityLabel: favoriteAccessibilityLabel
                ) {
                    toggleFavorite()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            guard guide.steps.count > 1 else { return }
            recentGuideID = guide.id
            recentGuideStepIndex = stepIndex
        }
        .onChange(of: stepIndex) { _, newValue in
            guard guide.steps.count > 1 else { return }
            recentGuideID = guide.id
            recentGuideStepIndex = newValue
        }
    }

    private func advance() {
        if isLastStep {
            if recentGuideID == guide.id {
                recentGuideID = ""
            }
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
