import SwiftUI

struct TabRootView: View {
    @State private var selectedTab: AppTab = .home
    @State private var isTeachPresented = false
    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .teach {
                    isTeachPresented = true
                } else {
                    selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            HomeView()
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
        .sheet(isPresented: $isTeachPresented) {
            TeachFlowView()
        }
        .preferredColorScheme(appearance.colorScheme)
        .animation(.easeInOut(duration: 0.3), value: appearanceRawValue)
    }
}

#Preview {
    TabRootView()
}
