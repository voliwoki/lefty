import Foundation

struct GuideDocument: Codable, Identifiable {
    let id: String
    let title: String
    let category: LearnCategory
    let icon: String
    let summary: String
    let steps: [GuideStepDocument]
}

struct GuideStepDocument: Codable, Identifiable {
    let number: Int
    let instruction: String

    var id: Int { number }
}
