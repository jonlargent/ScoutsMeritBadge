//
//  MeritBadgeJSONSyncService.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import Foundation
import SwiftData
import CryptoKit

/// Service that monitors the JSON file for changes and syncs with the database
@MainActor
class MeritBadgeJSONSyncService {
    
    private let modelContext: ModelContext
    private let jsonFilename: String
    private let remoteURL: URL?
    
    // UserDefaults keys for tracking
    private let lastSyncHashKey = "lastJSONSyncHash"
    private let lastSyncDateKey = "lastJSONSyncDate"
    
    init(modelContext: ModelContext, jsonFilename: String = "merit_badges_lite", remoteURL: String? = nil) {
        self.modelContext = modelContext
        self.jsonFilename = jsonFilename
        self.remoteURL = remoteURL != nil ? URL(string: remoteURL!) : nil
    }
    
    /// Check if JSON has changed and sync if needed
    func checkAndSyncIfNeeded() async throws {
        let jsonData: Data
        
        // Try to fetch from remote URL first, fall back to bundle
        if let remoteURL = remoteURL {
            do {
                print("🌐 Fetching JSON from remote URL: \(remoteURL)")
                let (data, response) = try await URLSession.shared.data(from: remoteURL)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ HTTP Error: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
                
                jsonData = data
                print("✅ Successfully fetched remote JSON (\(data.count) bytes)")
            } catch {
                print("⚠️ Failed to fetch remote JSON: \(error.localizedDescription)")
                print("   Falling back to bundled JSON...")
                
                // Fall back to bundled JSON
                guard let jsonURL = Bundle.main.url(forResource: jsonFilename, withExtension: "json") else {
                    print("❌ Bundled JSON file not found: \(jsonFilename).json")
                    throw error // Rethrow the original error
                }
                jsonData = try Data(contentsOf: jsonURL)
                print("✅ Using bundled JSON as fallback")
            }
        } else {
            // Use bundled JSON if no remote URL provided
            guard let jsonURL = Bundle.main.url(forResource: jsonFilename, withExtension: "json") else {
                print("❌ JSON file not found: \(jsonFilename).json")
                return
            }
            jsonData = try Data(contentsOf: jsonURL)
        }
        
        let currentHash = calculateHash(for: jsonData)
        let lastKnownHash = UserDefaults.standard.string(forKey: lastSyncHashKey)
        
        print("📊 JSON Sync Check:")
        print("   Current hash: \(currentHash)")
        print("   Last known hash: \(lastKnownHash ?? "none")")
        
        // If hashes don't match or no previous hash exists, sync is needed
        if currentHash != lastKnownHash {
            print("🔄 JSON file has changed, syncing...")
            try await syncJSONToDatabase(jsonData: jsonData)
            
            // Update stored hash
            UserDefaults.standard.set(currentHash, forKey: lastSyncHashKey)
            UserDefaults.standard.set(Date(), forKey: lastSyncDateKey)
            
            print("✅ JSON sync completed successfully")
            if let lastSync = UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date {
                print("   Last sync: \(lastSync.formatted())")
            }
        } else {
            print("✓ JSON file unchanged, no sync needed")
        }
    }
    
    /// Sync JSON data to database, preserving user progress
    private func syncJSONToDatabase(jsonData: Data) async throws {
        // Load badges from JSON
        let jsonBadges = try await MeritBadgeJSONLoader.loadFromData(jsonData)
        
        // Fetch existing badges from database
        let fetchDescriptor = FetchDescriptor<MeritBadge>()
        let existingBadges = try modelContext.fetch(fetchDescriptor)
        
        // Create lookup dictionary for existing badges by name
        var existingBadgesByName: [String: MeritBadge] = [:]
        for badge in existingBadges {
            existingBadgesByName[badge.name] = badge
        }
        
        var addedCount = 0
        var updatedCount = 0
        var removedCount = 0
        
        // Process each JSON badge
        for jsonBadge in jsonBadges {
            if let existingBadge = existingBadgesByName[jsonBadge.name] {
                // Badge exists - update it while preserving user progress
                let hasChanges = updateExistingBadge(existingBadge, from: jsonBadge)
                if hasChanges {
                    updatedCount += 1
                }
                // Remove from lookup so we know it was processed
                existingBadgesByName.removeValue(forKey: jsonBadge.name)
            } else {
                // New badge - add it
                modelContext.insert(jsonBadge)
                addedCount += 1
            }
        }
        
        // Any remaining badges in the lookup were not in JSON (removed badges)
        // Delete them UNLESS they are completed (preserve achievements)
        var keptCompletedCount = 0
        
        for (_, badge) in existingBadgesByName {
            if badge.isCompleted {
                // Keep completed badges to preserve user achievements
                keptCompletedCount += 1
                print("   ⭐ Keeping completed badge: \(badge.name)")
            } else {
                // Delete non-completed badges that were removed from JSON
                modelContext.delete(badge)
                removedCount += 1
                print("   🗑️ Removing badge: \(badge.name)")
            }
        }
        
        // Save changes
        try modelContext.save()
        
        print("📝 Sync Summary:")
        print("   ➕ Added: \(addedCount) new badges")
        print("   🔄 Updated: \(updatedCount) badges")
        print("   🗑️ Removed: \(removedCount) badges (not in JSON)")
        if keptCompletedCount > 0 {
            print("   ⭐ Kept: \(keptCompletedCount) completed badges (preserved achievements)")
        }
    }
    
    /// Update an existing badge with new JSON data while preserving user progress
    private func updateExistingBadge(_ existing: MeritBadge, from json: MeritBadge) -> Bool {
        var hasChanges = false
        
        // Update description if changed
        if existing.badgeDescription != json.badgeDescription {
            existing.badgeDescription = json.badgeDescription
            hasChanges = true
        }
        
        // Update category if changed
        if existing.category != json.category {
            existing.category = json.category
            hasChanges = true
        }
        
        // Update Eagle required status if changed
        if existing.isEagleRequired != json.isEagleRequired {
            existing.isEagleRequired = json.isEagleRequired
            hasChanges = true
        }
        
        // Update resource URL if changed
        if existing.resourceURL != json.resourceURL {
            existing.resourceURL = json.resourceURL
            hasChanges = true
        }
        
        // Update requirements while preserving completion status
        if existing.requirements != json.requirements {
            let oldRequirements = existing.requirements
            let oldCompletedStatus = existing.completedRequirements
            
            existing.requirements = json.requirements
            
            // Try to preserve completion status for requirements that match
            var newCompletedStatus = Array(repeating: false, count: json.requirements.count)
            
            for (newIndex, newReq) in json.requirements.enumerated() {
                // If this requirement existed before, preserve its status
                if let oldIndex = oldRequirements.firstIndex(of: newReq),
                   oldIndex < oldCompletedStatus.count {
                    newCompletedStatus[newIndex] = oldCompletedStatus[oldIndex]
                }
            }
            
            existing.completedRequirements = newCompletedStatus
            
            // Recalculate completion date based on new requirements
            if existing.completedRequirements.allSatisfy({ $0 }) && !existing.completedRequirements.isEmpty {
                // All requirements still complete
                if existing.dateCompleted == nil {
                    existing.dateCompleted = Date()
                }
            } else {
                // Some requirements no longer complete
                existing.dateCompleted = nil
            }
            
            hasChanges = true
        }
        
        return hasChanges
    }
    
    /// Calculate SHA256 hash of data
    private func calculateHash(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Force a resync (useful for debugging or manual refresh)
    func forceResync() async throws {
        print("🔄 Forcing resync...")
        UserDefaults.standard.removeObject(forKey: lastSyncHashKey)
        try await checkAndSyncIfNeeded()
    }
    
    /// Get last sync date
    func getLastSyncDate() -> Date? {
        return UserDefaults.standard.object(forKey: lastSyncDateKey) as? Date
    }
    
    /// Clear sync history (for testing)
    func clearSyncHistory() {
        UserDefaults.standard.removeObject(forKey: lastSyncHashKey)
        UserDefaults.standard.removeObject(forKey: lastSyncDateKey)
        print("🗑️ Sync history cleared")
    }
}
