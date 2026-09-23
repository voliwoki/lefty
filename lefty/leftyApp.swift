//
//  leftyApp.swift
//  lefty
//
//  Created by Nina Kolari on 9/15/26.
//

import SwiftUI
import SwiftData
import RevenueCat
import OSLog

@main
struct leftyApp: App {
    @State private var subscriptionService = SubscriptionService()

    init() {
        FontRegistrar.registerBundledFonts()
        configureRevenueCat()
    }

    var body: some Scene {
        WindowGroup {
            RootContainerView()
                .environment(subscriptionService)
                .task {
                    subscriptionService.start()
                }
        }
        .modelContainer(for: [FavoriteGuide.self, SavedGuide.self])
    }

    private func configureRevenueCat() {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: AppSecrets.revenueCatAPIKey)
        Logger(subsystem: "com.knk.lefty", category: "Subscription")
            .info("Purchases configured")
    }
}
