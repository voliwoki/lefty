import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.openURL) private var openURL

    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue
    @State private var isRestoring = false
    @State private var isPaywallPresented = false

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var feedbackURL: URL {
        // Safe: static mailto with encoded subject
        URL(string: "mailto:lefty@ninakolari.com?subject=Lefty%20feedback")!
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text(String(localized: "Settings"))
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColors.primaryText)

                    appearanceSection
                    loveLeftySection
                    subscriptionSection
                    thankYouSection
                    creatorsSection
                    aboutSection
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LeftyIconButton(systemImage: "xmark", accessibilityLabel: "Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isPaywallPresented) {
                PaywallSheet()
            }
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle(String(localized: "Appearance"))
            AppearanceSlider(
                selection: Binding(
                    get: { selectedAppearance },
                    set: { appearanceRawValue = $0.rawValue }
                )
            )
        }
    }

    private var loveLeftySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle(String(localized: "Love Lefty?"))

            VStack(spacing: 0) {
                settingsRow(
                    title: String(localized: "Rate on the App Store"),
                    systemImage: "star.fill"
                ) {
                    requestReview()
                }

                Divider()
                    .background(AppColors.separator)

                settingsRow(
                    title: String(localized: "Send feedback"),
                    systemImage: "envelope.fill"
                ) {
                    openURL(feedbackURL)
                }
            }
            .leftyCard(padding: 0)
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle(String(localized: "Subscription"))

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Text(String(localized: "Plan"))
                        .font(AppFont.body)
                        .foregroundStyle(AppColors.primaryText)
                    Spacer()
                    Text(subscription.isLeftyPlusActive
                         ? String(localized: "Lefty+")
                         : String(localized: "Free"))
                        .font(AppFont.subheadlineEmphasized)
                        .foregroundStyle(subscription.isLeftyPlusActive
                                         ? AppColors.accent
                                         : AppColors.secondaryText)
                }

                Button {
                    isPaywallPresented = true
                } label: {
                    Text(subscription.isLeftyPlusActive
                         ? String(localized: "Manage Lefty+")
                         : String(localized: "Get Lefty+"))
                        .font(AppFont.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
                .foregroundStyle(.white)

                Button {
                    Task {
                        isRestoring = true
                        await subscription.restorePurchases()
                        isRestoring = false
                    }
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        if isRestoring {
                            ProgressView()
                        }
                        Text(String(localized: "Restore purchases"))
                            .font(AppFont.subheadlineEmphasized)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.pressScale)
                .foregroundStyle(AppColors.brandPurple)
                .disabled(isRestoring)

                if let message = subscription.lastErrorMessage {
                    Text(message)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.accent)
                } else if let message = subscription.lastStatusMessage {
                    Text(message)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }

    private var thankYouSection: some View {
        Text(String(localized: "Thank you for downloading and using Lefty. Your support keeps Lefty going ad-free and 100% private."))
            .font(AppFont.body)
            .foregroundStyle(AppColors.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.lg)
            .background(AppColors.chipPurpleBg.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private var creatorsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle(String(localized: "A note from the creators"))

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(String(localized: "We're Nina and Oliver — both left-handed, both with the same school memory: trying to learn something while nobody could teach it for our hand. Mirroring never worked. YouTube assumed the wrong hand. So we built Lefty — clear left-handed steps for lefties and the people who love them."))
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppSpacing.lg) {
                    creatorChip(name: String(localized: "Oliver"), age: 13)
                    creatorChip(name: String(localized: "Nina"), age: 51)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .leftyCard()
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            sectionTitle(String(localized: "About"))
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Lefty")
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
                Text(String(localized: "Same world. Just left."))
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                Text("Version \(appVersion)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .padding(.top, AppSpacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .leftyCard()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppFont.headline)
            .foregroundStyle(AppColors.primaryText)
    }

    private func settingsRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.brandPurple)
                    .frame(width: 28, height: 28)
                Text(title)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.primaryText)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.separator)
            }
            .padding(.horizontal, AppSpacing.lg)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressScale)
    }

    private func creatorChip(name: String, age: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(name)
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            Text(String(localized: "Age \(age)"))
                .font(AppFont.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.chipPurpleBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }
}

private struct AppearanceSlider: View {
    @Binding var selection: AppAppearance
    @Namespace private var namespace
    @State private var displayedSelection: AppAppearance

    init(selection: Binding<AppAppearance>) {
        self._selection = selection
        self._displayedSelection = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppAppearance.allCases) { option in
                Text(option.label)
                    .font(AppFont.subheadlineEmphasized)
                    .foregroundStyle(displayedSelection == option ? .white : AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background {
                        if displayedSelection == option {
                            Capsule()
                                .fill(AppColors.accent)
                                .matchedGeometryEffect(id: "selection", in: namespace)
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
        .background(AppColors.surface)
        .clipShape(Capsule())
    }
}

#Preview {
    SettingsView()
        .environment(SubscriptionService())
}
