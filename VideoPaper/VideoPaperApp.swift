//
//  VideoPaperApp.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI
import SwiftData

@main
struct VideoPaperApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SDWallpaperVideo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
