import Foundation

struct GuideDocument: Codable, Identifiable {
    let id: String
    let title: String
    let category: LearnCategory
    let icon: String
    let summary: String
    let steps: [GuideStepDocument]

    /// Rough reading/following time, derived from step count (not authored per guide).
    var estimatedMinutes: Int { max(1, steps.count) }
}

struct GuideStepDocument: Codable, Identifiable {
    let number: Int
    let instruction: String

    var id: Int { number }
}
