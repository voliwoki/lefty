import SwiftUI

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscription
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue
    @State private var isRestoring = false

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    Text("Settings")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColors.primaryText)

                    appearanceSection
                    restoreSection
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
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Appearance")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            AppearanceSlider(
                selection: Binding(
                    get: { selectedAppearance },
                    set: { appearanceRawValue = $0.rawValue }
                )
            )
        }
    }

    private var restoreSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
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
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("About")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Lefty")
                    .font(AppFont.title)
                    .foregroundStyle(AppColors.primaryText)
                Text("Same world. Just left.")
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
