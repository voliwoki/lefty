//
//  leftyApp.swift
//  lefty
//
//  Created by Nina Kolari on 9/15/26.
//

import SwiftUI
import SwiftData

@main
struct leftyApp: App {
    init() {
        FontRegistrar.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            TabRootView()
        }
        .modelContainer(for: [FavoriteGuide.self, SavedGuide.self])
    }
}
