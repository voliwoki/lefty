enum AppTab: CaseIterable {
    case home, learn, teach, practice, myLefty

    var title: String {
        switch self {
        case .home: "Home"
        case .learn: "Learn"
        case .teach: "Teach"
        case .practice: "Practice"
        case .myLefty: "My Lefty"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .learn: "book.fill"
        case .teach: "plus.circle.fill"
        case .practice: "pencil.and.scribble"
        case .myLefty: "person.crop.circle.fill"
        }
    }
}
