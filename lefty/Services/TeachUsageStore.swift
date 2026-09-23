import Foundation
import OSLog

/// Tracks free Teach conversions. Lefty+ bypasses the limit via `SubscriptionService`.
/// Static helpers so we never touch MainActor-isolated `UserDefaults.standard` from a View init.
enum TeachUsageStore {
    static let freeMonthlyAllowance = 3

    private static let logger = Logger(subsystem: "com.knk.lefty", category: "TeachUsage")

    private enum Keys {
        static let count = "teachUsage.count"
        static let monthStamp = "teachUsage.monthStamp"
    }

    @MainActor
    static var usedThisMonth: Int {
        resetIfNeeded()
        return UserDefaults.standard.integer(forKey: Keys.count)
    }

    @MainActor
    static var remainingFreeConversions: Int {
        max(0, freeMonthlyAllowance - usedThisMonth)
    }

    @MainActor
    static func canStartConversion(isLeftyPlusActive: Bool) -> Bool {
        if isLeftyPlusActive { return true }
        return remainingFreeConversions > 0
    }

    /// Call only after a usable guide is delivered (high / uncertain confidence).
    @MainActor
    static func recordSuccessfulConversion(isLeftyPlusActive: Bool) {
        guard !isLeftyPlusActive else { return }
        resetIfNeeded()
        let next = usedThisMonth + 1
        UserDefaults.standard.set(next, forKey: Keys.count)
        logger.info("Teach usage now \(next, privacy: .public)/\(freeMonthlyAllowance, privacy: .public)")
    }

    @MainActor
    private static func resetIfNeeded() {
        let stamp = currentMonthStamp()
        let defaults = UserDefaults.standard
        let stored = defaults.string(forKey: Keys.monthStamp)
        if stored != stamp {
            defaults.set(stamp, forKey: Keys.monthStamp)
            defaults.set(0, forKey: Keys.count)
        }
    }

    @MainActor
    private static func currentMonthStamp() -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: .now)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        return "\(year)-\(month)"
    }
}
