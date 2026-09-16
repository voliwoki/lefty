enum AppTab: CaseIterable {
    case home, learn, teach, settings, myLefty

    var title: String {
        switch self {
        case .home: "Home"
        case .learn: "Learn"
        case .teach: "Teach"
        case .settings: "Settings"
        case .myLefty: "My Lefty"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .learn: "book.fill"
        case .teach: "plus.circle.fill"
        case .settings: "gearshape.fill"
        case .myLefty: "person.crop.circle.fill"
        }
    }
}
