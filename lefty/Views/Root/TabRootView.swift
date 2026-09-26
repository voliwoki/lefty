import SwiftUI

struct TabRootView: View {
    @Environment(AppNavigationCoordinator.self) private var navigation
    @AppStorage("appearancePreference") private var appearanceRawValue: String = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColors.secondaryText)
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { navigation.selectedTab },
            set: { newValue in
                if newValue == .teach {
                    navigation.isTeachPresented = true
                } else {
                    navigation.selectedTab = newValue
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

            MyLeftyView()
                .tabItem { Label(AppTab.myLefty.title, systemImage: AppTab.myLefty.icon) }
                .tag(AppTab.myLefty)
        }
        .tint(AppColors.accent)
        .sheet(isPresented: Binding(
            get: { navigation.isTeachPresented },
            set: { navigation.isTeachPresented = $0 }
        )) {
            TeachFlowView()
        }
        .preferredColorScheme(appearance.colorScheme)
        .animation(.easeInOut(duration: 0.3), value: appearanceRawValue)
    }
}

#Preview {
    TabRootView()
        .environment(AppNavigationCoordinator())
        .environment(SubscriptionService())
}
