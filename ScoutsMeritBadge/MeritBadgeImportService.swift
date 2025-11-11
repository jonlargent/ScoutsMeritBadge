//
//  MeritBadgeImportService.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import Foundation
import SwiftData
import Combine
import Combine
import Combine

/// Manages the import of merit badge data from web scraping
@MainActor
class MeritBadgeImportService: ObservableObject {
    @Published var isImporting = false
    @Published var progress: Double = 0.0
    @Published var statusMessage = ""
    @Published var errorMessage: String?
    
    private let scraper = MeritBadgeScraper()
    
    /// Imports all merit badges from the web
    func importAllBadges(into modelContext: ModelContext) async {
        isImporting = true
        progress = 0.0
        errorMessage = nil
        statusMessage = "Fetching merit badge list..."
        
        do {
            // Step 1: Get the list of all badges
            let badgeList = try await scraper.fetchAllMeritBadges()
            statusMessage = "Found \(badgeList.count) merit badges"
            
            // Step 2: Fetch details for each badge
            let totalBadges = Double(badgeList.count)
            
            for (index, badgeData) in badgeList.enumerated() {
                statusMessage = "Loading \(badgeData.name)... (\(index + 1)/\(badgeList.count))"
                
                do {
                    // Fetch detailed information
                    let detailedData: MeritBadgeData
                    if let url = badgeData.resourceURL {
                        detailedData = try await scraper.fetchMeritBadgeDetails(url: url)
                    } else {
                        detailedData = badgeData
                    }
                    
                    // Save to database
                    let badge = MeritBadge(
                        name: detailedData.name,
                        badgeDescription: detailedData.badgeDescription,
                        category: detailedData.category,
                        isEagleRequired: detailedData.isEagleRequired,
                        requirements: detailedData.requirements,
                        resourceURL: detailedData.resourceURL
                    )
                    
                    modelContext.insert(badge)
                    
                } catch {
                    // Log error but continue with other badges
                    print("Failed to fetch details for \(badgeData.name): \(error)")
                }
                
                progress = Double(index + 1) / totalBadges
            }
            
            // Save all changes
            try modelContext.save()
            
            statusMessage = "Successfully imported \(badgeList.count) merit badges!"
            
            // Clear status after a delay
            try? await Task.sleep(for: .seconds(2))
            statusMessage = ""
            
        } catch {
            errorMessage = error.localizedDescription
            statusMessage = "Import failed"
        }
        
        isImporting = false
    }
    
    /// Imports a single badge by URL
    func importSingleBadge(url: String, into modelContext: ModelContext) async {
        isImporting = true
        errorMessage = nil
        statusMessage = "Fetching badge details..."
        
        do {
            let badgeData = try await scraper.fetchMeritBadgeDetails(url: url)
            
            let badge = MeritBadge(
                name: badgeData.name,
                badgeDescription: badgeData.badgeDescription,
                category: badgeData.category,
                isEagleRequired: badgeData.isEagleRequired,
                requirements: badgeData.requirements,
                resourceURL: badgeData.resourceURL
            )
            
            modelContext.insert(badge)
            try modelContext.save()
            
            statusMessage = "Successfully imported \(badgeData.name)!"
            
            try? await Task.sleep(for: .seconds(1))
            statusMessage = ""
            
        } catch {
            errorMessage = error.localizedDescription
            statusMessage = "Import failed"
        }
        
        isImporting = false
    }
}
