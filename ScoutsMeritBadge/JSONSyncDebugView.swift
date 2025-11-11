//
//  JSONSyncDebugView.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI
import SwiftData

/// Debug view to test and demonstrate JSON sync functionality
struct JSONSyncDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var badges: [MeritBadge]
    
    @State private var syncStatus = "Ready"
    @State private var lastSyncDate: Date?
    @State private var syncStats = SyncStats()
    
    struct SyncStats {
        var totalBadges = 0
        var added = 0
        var updated = 0
        var removed = 0
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Current Status") {
                    LabeledContent("Total Badges in DB", value: "\(badges.count)")
                    LabeledContent("Status", value: syncStatus)
                    
                    if let lastSync = lastSyncDate {
                        LabeledContent("Last Sync", value: lastSync.formatted(date: .abbreviated, time: .shortened))
                    } else {
                        LabeledContent("Last Sync", value: "Never")
                    }
                }
                
                if syncStats.totalBadges > 0 {
                    Section("Last Sync Stats") {
                        LabeledContent("Total in JSON", value: "\(syncStats.totalBadges)")
                        LabeledContent("Added", value: "\(syncStats.added)")
                            .foregroundStyle(syncStats.added > 0 ? .green : .primary)
                        LabeledContent("Updated", value: "\(syncStats.updated)")
                            .foregroundStyle(syncStats.updated > 0 ? .orange : .primary)
                        LabeledContent("Removed", value: "\(syncStats.removed)")
                            .foregroundStyle(syncStats.removed > 0 ? .red : .primary)
                    }
                }
                
                Section("Actions") {
                    Button {
                        Task {
                            await performSync()
                        }
                    } label: {
                        Label("Check & Sync", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button {
                        Task {
                            await forceResync()
                        }
                    } label: {
                        Label("Force Resync", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                    }
                    
                    Button(role: .destructive) {
                        clearSyncHistory()
                    } label: {
                        Label("Clear Sync History", systemImage: "trash")
                    }
                }
                
                Section("Database Actions") {
                    Button(role: .destructive) {
                        clearDatabase()
                    } label: {
                        Label("Clear All Badges", systemImage: "trash.fill")
                    }
                }
                
                Section("Testing Instructions") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Test:")
                            .font(.headline)
                        
                        Text("1. Note the current badge count")
                        Text("2. Edit merit_badges_lite.json (add/remove badges)")
                        Text("3. Tap 'Force Resync' to see changes")
                        Text("4. Check the sync stats to see what changed")
                        Text("5. Verify that user progress was preserved")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("JSON Sync Debug")
            .task {
                loadSyncInfo()
            }
        }
    }
    
    private func loadSyncInfo() {
        let syncService = MeritBadgeJSONSyncService(
            modelContext: modelContext,
            jsonFilename: "merit_badges_lite"
        )
        lastSyncDate = syncService.getLastSyncDate()
    }
    
    private func performSync() async {
        syncStatus = "Checking..."
        
        let syncService = MeritBadgeJSONSyncService(
            modelContext: modelContext,
            jsonFilename: "merit_badges_lite"
        )
        
        do {
            try await syncService.checkAndSyncIfNeeded()
            
            await MainActor.run {
                syncStatus = "✅ Sync Complete"
                lastSyncDate = syncService.getLastSyncDate()
            }
            
            // Wait a moment then reset status
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                syncStatus = "Ready"
            }
        } catch {
            await MainActor.run {
                syncStatus = "❌ Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func forceResync() async {
        syncStatus = "Force Syncing..."
        
        let syncService = MeritBadgeJSONSyncService(
            modelContext: modelContext,
            jsonFilename: "merit_badges_lite"
        )
        
        do {
            try await syncService.forceResync()
            
            await MainActor.run {
                syncStatus = "✅ Force Sync Complete"
                lastSyncDate = syncService.getLastSyncDate()
                
                // Update stats
                syncStats.totalBadges = badges.count
            }
            
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                syncStatus = "Ready"
            }
        } catch {
            await MainActor.run {
                syncStatus = "❌ Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func clearSyncHistory() {
        let syncService = MeritBadgeJSONSyncService(
            modelContext: modelContext,
            jsonFilename: "merit_badges_lite"
        )
        syncService.clearSyncHistory()
        lastSyncDate = nil
        syncStatus = "Sync history cleared"
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                syncStatus = "Ready"
            }
        }
    }
    
    private func clearDatabase() {
        for badge in badges {
            modelContext.delete(badge)
        }
        try? modelContext.save()
        
        syncStatus = "Database cleared"
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                syncStatus = "Ready"
            }
        }
    }
}

#Preview {
    JSONSyncDebugView()
        .modelContainer(for: MeritBadge.self, inMemory: true)
}
