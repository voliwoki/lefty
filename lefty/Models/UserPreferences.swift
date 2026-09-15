import SwiftData

@Model
final class UserPreferences {
    var tipIndex: Int
    var appearanceOverrideRawValue: String?

    init(tipIndex: Int = 0, appearanceOverrideRawValue: String? = nil) {
        self.tipIndex = tipIndex
        self.appearanceOverrideRawValue = appearanceOverrideRawValue
    }
}
