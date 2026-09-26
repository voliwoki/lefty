import SwiftUI
import SwiftData

private enum LibrarySection: CaseIterable, Hashable {
    case saved, favorites

    var title: String {
        switch self {
        case .saved: "Saved"
        case .favorites: "Favorites"
        }
    }
}

struct MyLeftyView: View {
    @Environment(SubscriptionService.self) private var subscription
    @Environment(AppNavigationCoordinator.self) private var navigation
    @Query(sort: \FavoriteGuide.createdAt, order: .reverse) private var favorites: [FavoriteGuide]
    @Query(sort: \SavedGuide.createdAt, order: .reverse) private var savedGuides: [SavedGuide]

    @State private var selectedSection: LibrarySection = .saved
    @State private var isSettingsPresented = false
    @State private var isPaywallPresented = false

    private var favoritedGuides: [GuideDocument] {
        favorites.compactMap { favorite in
            LearnContentLoader.guides.first { $0.id == favorite.guideId }
        }
    }

    private var isCurrentSectionEmpty: Bool {
        selectedSection == .saved ? savedGuides.isEmpty : favoritedGuides.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    planCard
                    sectionToggle

                    if isCurrentSectionEmpty {
                        emptyState
                    } else if selectedSection == .saved {
                        savedGuidesList
                    } else {
                        favoritesList
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .toolbar(.hidden)
            .navigationDestination(for: String.self) { guideId in
                if let guide = LearnContentLoader.guides.first(where: { $0.id == guideId }) {
                    GuideDetailView(guide: guide)
                }
            }
            .navigationDestination(for: SavedGuide.self) { guide in
                SavedGuideDetailView(guide: guide)
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
            .sheet(isPresented: $isPaywallPresented) {
                PaywallSheet()
            }
        }
    }

    private var header: some View {
        HStack {
            Text("My Lefty")
                .font(AppFont.largeTitle)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
            Button {
                isSettingsPresented = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 44, height: 44)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.pressScale)
            .accessibilityLabel(String(localized: "Settings"))
        }
    }

    private var planCard: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(subscription.isLeftyPlusActive ? "Lefty+" : "Free plan")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColors.primaryText)
                Text(
                    subscription.isLeftyPlusActive
                        ? String(localized: "Unlimited Teach conversions")
                        : TeachUsageStore.statusText(isLeftyPlusActive: false)
                )
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
            }
            Spacer(minLength: AppSpacing.sm)
            if !subscription.isLeftyPlusActive {
                Button {
                    isPaywallPresented = true
                } label: {
                    Text("Get Lefty+")
                        .font(AppFont.subheadlineEmphasized)
                        .padding(.horizontal, AppSpacing.md)
                        .frame(minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.brandPurple)
            }
        }
        .leftyCard()
    }

    private var sectionToggle: some View {
        LibrarySectionSlider(selection: $selectedSection)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            HandDrawnHandIcon(size: 72)
            Text("Nothing saved yet")
                .font(AppFont.title)
                .foregroundStyle(AppColors.primaryText)
            Text("Tap the heart on any guide, or save a Teach result. It'll be waiting here.")
                .font(AppFont.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                navigation.switchTo(.learn)
            } label: {
                Text("Browse Learn")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
            .padding(.top, AppSpacing.sm)

            Button {
                navigation.openTeach()
            } label: {
                Text("or teach me something")
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(AppColors.accent)
            }
            .buttonStyle(.pressScale)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xl)
    }

    private var savedGuidesList: some View {
        LazyVStack(spacing: AppSpacing.md) {
            ForEach(savedGuides) { guide in
                NavigationLink(value: guide) {
                    savedGuideRow(guide)
                }
                .buttonStyle(.pressScale)
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

    private var favoritesList: some View {
        LazyVStack(spacing: AppSpacing.md) {
            ForEach(favoritedGuides) { guide in
                NavigationLink(value: guide.id) {
                    GuideRow(guide: guide)
                }
                .buttonStyle(.pressScale)
            }
        }
    }
}

private struct LibrarySectionSlider: View {
    @Binding var selection: LibrarySection
    @Namespace private var namespace
    @State private var displayedSelection: LibrarySection

    init(selection: Binding<LibrarySection>) {
        self._selection = selection
        self._displayedSelection = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(LibrarySection.allCases, id: \.self) { option in
                Text(option.title)
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(displayedSelection == option ? AppColors.primaryText : AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background {
                        if displayedSelection == option {
                            Capsule()
                                .fill(.white)
                                .matchedGeometryEffect(id: "librarySelection", in: namespace)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            displayedSelection = option
                        }
                        selection = option
                    }
                    .accessibilityAddTraits(displayedSelection == option ? .isSelected : [])
            }
        }
        .padding(4)
        .background(AppColors.chipPurpleBg)
        .clipShape(Capsule())
    }
}

#Preview {
    MyLeftyView()
        .environment(SubscriptionService())
        .environment(AppNavigationCoordinator())
        .modelContainer(for: [FavoriteGuide.self, SavedGuide.self], inMemory: true)
}
