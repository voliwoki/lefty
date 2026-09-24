import Foundation

enum AppSecrets {
    struct Values: Equatable {
        let teachWorkerURL: URL
        let leftyAppSecret: String
    }

    /// Public RevenueCat SDK key.
    /// - Debug: Test Store (`test_…`) for simulator / Xcode runs
    /// - Release/TestFlight: App Store (`appl_…`) — Test Store keys intentionally crash Release builds
    static var revenueCatAPIKey: String {
        if
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["RevenueCatAPIKey"] as? String,
            !key.isEmpty,
            !key.hasPrefix("REPLACE"),
            isKeyAllowedInThisBuild(key)
        {
            return key
        }

        #if DEBUG
        return "test_FpNSeORiadRrKIrxPpXNcVcZjuS"
        #else
        return "appl_rPWOgfnUTFvBsOyZQAWyjbywbIM"
        #endif
    }

    private static func isKeyAllowedInThisBuild(_ key: String) -> Bool {
        #if DEBUG
        return true
        #else
        // RevenueCat fatalErrors if a test_ key is used in Release / TestFlight.
        return !key.hasPrefix("test_")
        #endif
    }

    static var current: Values? {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let workerURLString = plist["TeachWorkerURL"] as? String,
            let workerURL = URL(string: workerURLString),
            let secret = plist["LeftyAppSecret"] as? String,
            !secret.isEmpty,
            !secret.hasPrefix("REPLACE")
        else {
            return nil
        }
        return Values(teachWorkerURL: workerURL, leftyAppSecret: secret)
    }
}
