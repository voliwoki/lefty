import Observation

@MainActor
@Observable
final class AppNavigationCoordinator {
    var selectedTab: AppTab = .home
    var isTeachPresented = false

    func switchTo(_ tab: AppTab) {
        selectedTab = tab
    }

    func openTeach() {
        isTeachPresented = true
    }
}
