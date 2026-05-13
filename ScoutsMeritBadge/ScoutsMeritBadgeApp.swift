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
    private static let cloudKitContainerIdentifier = "iCloud.com.largentlabs.ScoutsMeritBadge"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeritBadge.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private(Self.cloudKitContainerIdentifier)
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully")
            return container
        } catch {
            print("⚠️ Failed to create ModelContainer: \(error)")
            print("📝 Error details: \(error.localizedDescription)")

            // Keep the app usable if CloudKit setup fails on a device.
            do {
                let localConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                let container = try ModelContainer(for: schema, configurations: [localConfiguration])
                print("✅ ModelContainer created successfully without CloudKit")
                return container
                
            } catch {
                print("❌ Failed to create local ModelContainer")
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
