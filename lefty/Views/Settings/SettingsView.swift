import SwiftUI

struct SettingsView: View {
    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue

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
                    appearanceSection
                    aboutSection
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .navigationTitle("Settings")
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Appearance")
                .font(AppFont.headline)
                .foregroundStyle(AppColors.primaryText)
            VStack(spacing: 0) {
                ForEach(AppAppearance.allCases) { option in
                    appearanceRow(option)
                    if option != AppAppearance.allCases.last {
                        Divider()
                    }
                }
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
    }

    private func appearanceRow(_ option: AppAppearance) -> some View {
        Button {
            appearanceRawValue = option.rawValue
        } label: {
            HStack {
                Text(option.label)
                    .font(AppFont.body)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
                if selectedAppearance == option {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedAppearance == option ? .isSelected : [])
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

#Preview {
    SettingsView()
}
