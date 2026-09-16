import SwiftUI

struct TabRootView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var isTeachPresented = false
    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onTeachTapped: { isTeachPresented = true },
                onBrowseLearnTapped: { selectedTab = .learn }
            )
            .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.icon) }
            .tag(AppTab.home)

            LearnView()
                .tabItem { Label(AppTab.learn.title, systemImage: AppTab.learn.icon) }
                .tag(AppTab.learn)

            Color.clear
                .tabItem { Label(AppTab.teach.title, systemImage: AppTab.teach.icon) }
                .tag(AppTab.teach)

            SettingsView()
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.icon) }
                .tag(AppTab.settings)

            MyLeftyView()
                .tabItem { Label(AppTab.myLefty.title, systemImage: AppTab.myLefty.icon) }
                .tag(AppTab.myLefty)
        }
        .tint(AppColors.accent)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .teach {
                isTeachPresented = true
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $isTeachPresented) {
            TeachFlowView()
        }
        .preferredColorScheme(appearance.colorScheme)
    }
}

#Preview {
    TabRootView()
}
