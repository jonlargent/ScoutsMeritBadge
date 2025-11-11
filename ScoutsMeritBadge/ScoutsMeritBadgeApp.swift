//
//  ScoutsMeritBadgeApp.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI
import SwiftData

@main
struct ScoutsMeritBadgeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeritBadge.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully")
            return container
        } catch {
            print("⚠️ Failed to create ModelContainer: \(error)")
            print("📝 Error details: \(error.localizedDescription)")
            
            // Attempt recovery by creating a fresh container
            do {
                // Get the default store URL
                let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let storeURL = appSupportURL.appendingPathComponent("default.store")
                
                print("📂 Database location: \(storeURL.path)")
                
                // Remove the existing database files
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: storeURL.path) {
                    print("🗑️ Removing old database...")
                    try? fileManager.removeItem(at: storeURL)
                }
                
                // Also try to remove related files
                let supportFiles = [
                    storeURL.deletingLastPathComponent().appendingPathComponent("default.store-wal"),
                    storeURL.deletingLastPathComponent().appendingPathComponent("default.store-shm")
                ]
                for file in supportFiles {
                    if fileManager.fileExists(atPath: file.path) {
                        try? fileManager.removeItem(at: file)
                    }
                }
                
                // Try creating container again
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ ModelContainer created successfully after cleanup")
                return container
                
            } catch {
                print("❌ Failed to create ModelContainer even after cleanup")
                print("❌ Error: \(error)")
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
