import Foundation
import SwiftData

@Model
final class FavoriteGuide {
    var guideId: String
    var createdAt: Date

    init(guideId: String, createdAt: Date = .now) {
        self.guideId = guideId
        self.createdAt = createdAt
    }
}
