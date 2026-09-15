enum LearnCategory: String, Codable, CaseIterable, Identifiable {
    case writing = "Writing"
    case scissors = "Scissors"
    case kitchen = "Kitchen"
    case instruments = "Instruments"
    case crafts = "Crafts"

    var id: String { rawValue }

    var tone: ChipTone {
        switch self {
        case .writing: .yellow
        case .scissors: .pink
        case .kitchen: .green
        case .instruments: .purple
        case .crafts: .purple
        }
    }
}
