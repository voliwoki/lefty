import Foundation

enum AppSecrets {
    struct Values: Equatable {
        let teachWorkerURL: URL
        let leftyAppSecret: String
    }

    /// Public RevenueCat SDK key (Test Store for Shipaton). Prefer Secrets.plist override.
    static var revenueCatAPIKey: String {
        if
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["RevenueCatAPIKey"] as? String,
            !key.isEmpty,
            !key.hasPrefix("REPLACE")
        {
            return key
        }
        // Test Store public key — safe for client; swap for appl_ when App Store ships.
        return "test_FpNSeORiadRrKIrxPpXNcVcZjuS"
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
