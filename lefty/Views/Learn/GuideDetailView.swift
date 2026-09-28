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
    private var isLastStep: Bool { stepIndex == guide.steps.count - 1 }
    private var favoriteIconName: String { isFavorited ? "heart.fill" : "heart" }
    private var favoriteAccessibilityLabel: String { isFavorited ? "Remove from favorites" : "Add to favorites" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Step \(stepIndex + 1) of \(guide.steps.count)")
                        .font(AppFont.subheadlineEmphasized)
                        .foregroundStyle(AppColors.secondaryText)

                    StepProgressBar(total: guide.steps.count, currentIndex: stepIndex)
                }
                .padding(.top, AppSpacing.md)

                Text(currentStep.instruction)
                    .font(AppFont.body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .id(stepIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: goingForward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: goingForward ? .leading : .trailing).combined(with: .opacity)
                    ))
                    .leftyCard(padding: AppSpacing.lg)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeInOut(duration: 0.25), value: stepIndex)
        }
        .background(AppColors.background)
        .safeAreaInset(edge: .bottom) {
            LeftyActionBar(
                primaryTitle: isLastStep ? String(localized: "Done") : String(localized: "Next step"),
                primaryTrailingIcon: isLastStep ? nil : "arrow.right",
                primaryAction: advance
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
                    .lineLimit(1)
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
