import Foundation

enum GuideConfidence: String, Codable {
    case high
    case uncertain
    case needMoreInfo
    case unsafe
}

struct GuideStep: Codable, Identifiable, Hashable {
    let number: Int
    let instruction: String

    var id: Int { number }
}

struct GeneratedGuide: Codable {
    var title: String
    var estimatedMinutes: Int?
    var summary: String
    var whatChanges: String
    var whatStaysSame: String
    var confidence: GuideConfidence
    var clarifyingQuestion: String?
    var steps: [GuideStep]
    var safetyNote: String?
}
