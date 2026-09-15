import Foundation

struct PopularGuideStub: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let tone: ChipTone

    static let samples: [PopularGuideStub] = [
        PopularGuideStub(title: "Comfortable Handwriting", icon: "pencil.and.outline", tone: .yellow),
        PopularGuideStub(title: "Left-Handed Scissors Grip", icon: "scissors", tone: .pink),
        PopularGuideStub(title: "Guitar Basics", icon: "music.note", tone: .purple),
        PopularGuideStub(title: "Kitchen Knife Safety", icon: "fork.knife", tone: .green)
    ]
}
