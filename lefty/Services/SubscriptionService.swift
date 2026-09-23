import Foundation
import OSLog
import RevenueCat
import Observation

@MainActor
@Observable
final class SubscriptionService {
    static let entitlementID = "lefty_plus"

    private(set) var isLeftyPlusActive = false
    private(set) var isLoadingEntitlement = true
    private(set) var lastErrorMessage: String?

    private let logger = Logger(subsystem: "com.knk.lefty", category: "Subscription")
    private var observationTask: Task<Void, Never>?

    func start() {
        guard observationTask == nil else { return }
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await info in Purchases.shared.customerInfoStream {
                self.apply(customerInfo: info)
            }
        }
    }

    func refresh() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            apply(customerInfo: info)
        } catch {
            logger.error("customerInfo failed: \(error.localizedDescription, privacy: .public)")
            lastErrorMessage = String(localized: "Couldn't check Lefty+ status. Try again.")
            isLoadingEntitlement = false
        }
    }

    func restorePurchases() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            apply(customerInfo: info)
            lastErrorMessage = nil
        } catch {
            logger.error("restore failed: \(error.localizedDescription, privacy: .public)")
            lastErrorMessage = String(localized: "Couldn't restore purchases. Try again.")
        }
    }

    private func apply(customerInfo: CustomerInfo) {
        isLeftyPlusActive = customerInfo.entitlements[Self.entitlementID]?.isActive == true
        isLoadingEntitlement = false
        lastErrorMessage = nil
    }
}
