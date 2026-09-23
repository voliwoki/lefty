import SwiftUI
import OSLog
import RevenueCat
import RevenueCatUI

struct PaywallSheet: View {
    @Environment(SubscriptionService.self) private var subscription
    @Environment(\.dismiss) private var dismiss

    /// When set (e.g. onboarding), called instead of relying on sheet dismiss alone.
    var onFinished: (() -> Void)? = nil

    @State private var offering: Offering?
    @State private var isLoading = true
    @State private var loadError: String?

    private let logger = Logger(subsystem: "com.knk.lefty", category: "Paywall")

    var body: some View {
        Group {
            if isLoading {
                ProgressView(String(localized: "Loading Lefty+…"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.background)
            } else if let offering {
                PaywallView(offering: offering, displayCloseButton: true)
                    .preferredColorScheme(.light)
                    .onPurchaseCompleted { info in
                        if info.entitlements[SubscriptionService.entitlementID]?.isActive == true {
                            finish()
                        }
                    }
                    .onRestoreCompleted { info in
                        if info.entitlements[SubscriptionService.entitlementID]?.isActive == true {
                            finish()
                        }
                    }
                    .onRequestedDismissal {
                        finish()
                    }
            } else {
                ContentUnavailableView {
                    Label(String(localized: "Couldn't load Lefty+"), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(loadError ?? String(localized: "Check your connection and try again."))
                } actions: {
                    Button(String(localized: "Try again")) {
                        Task { await loadOffering() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)

                    if onFinished != nil {
                        Button(String(localized: "Continue without Lefty+")) {
                            finish()
                        }
                        .font(AppFont.subheadlineEmphasized)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            }
        }
        .task {
            await subscription.refresh()
            await loadOffering()
        }
    }

    private func finish() {
        if let onFinished {
            onFinished()
        } else {
            dismiss()
        }
    }

    private func loadOffering() async {
        isLoading = true
        loadError = nil
        do {
            _ = try? await Purchases.shared.syncAttributesAndOfferingsIfNeeded()
            let offerings = try await Purchases.shared.offerings()
            guard let current = offerings.current else {
                loadError = String(localized: "No subscription offering is available yet.")
                offering = nil
                isLoading = false
                return
            }

            logger.info(
                "Offering \(current.identifier, privacy: .public) packages=\(current.availablePackages.count, privacy: .public) hasPaywall=\(current.hasPaywall, privacy: .public)"
            )
            if !current.hasPaywall {
                logger.error("Offering has products but no published paywall template — SDK will show fallback")
            }

            offering = current
            isLoading = false
        } catch {
            logger.error("offerings failed: \(error.localizedDescription, privacy: .public)")
            loadError = (error as? LocalizedError)?.errorDescription
                ?? String(localized: "Something went wrong loading plans.")
            offering = nil
            isLoading = false
        }
    }
}

#Preview {
    PaywallSheet()
        .environment(SubscriptionService())
}
