import Foundation

enum AppSecrets {
    struct Values: Equatable {
        let teachWorkerURL: URL
        let leftyAppSecret: String
    }

    /// App Store public SDK key only. Never use RevenueCat Test Store (`test_…`) keys.
    static let appStoreAPIKey = "appl_rPWOgfnUTFvBsOyZQAWyjbywbIM"

    static var revenueCatAPIKey: String {
        if
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["RevenueCatAPIKey"] as? String,
            !key.isEmpty,
            !key.hasPrefix("REPLACE"),
            !key.hasPrefix("test_")
        {
            return key
        }
        return appStoreAPIKey
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
