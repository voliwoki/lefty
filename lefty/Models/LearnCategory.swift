enum LearnCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case writing = "Writing"
    case toolsAndAccessories = "Tools & Accessories"
    case sports = "Sports"
    case instruments = "Instruments"
    case kitchen = "Kitchen"

    var id: String { rawValue }

    var tone: ChipTone {
        switch self {
        case .writing: .yellow
        case .toolsAndAccessories: .green
        case .sports: .pink
        case .instruments: .purple
        case .kitchen: .blue
        }
    }

    var icon: String {
        switch self {
        case .writing: "pencil"
        case .toolsAndAccessories: "wrench.and.screwdriver.fill"
        case .sports: "sportscourt.fill"
        case .instruments: "music.note"
        case .kitchen: "fork.knife"
        }
    }
}
