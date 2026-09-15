import SwiftUI

struct TabRootView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var isTeachPresented = false

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

            PracticeView()
                .tabItem { Label(AppTab.practice.title, systemImage: AppTab.practice.icon) }
                .tag(AppTab.practice)

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
    }
}

#Preview {
    TabRootView()
}
