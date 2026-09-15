import Foundation
import SwiftData

@Model
final class SavedGuide {
    var id: String
    var title: String
    var stepsData: Data
    var createdAt: Date

    init(id: String = UUID().uuidString, title: String, steps: [GuideStep], createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.stepsData = (try? JSONEncoder().encode(steps)) ?? Data()
        self.createdAt = createdAt
    }

    var steps: [GuideStep] {
        (try? JSONDecoder().decode([GuideStep].self, from: stepsData)) ?? []
    }
}
