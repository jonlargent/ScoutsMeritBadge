//
//  MeritBadge.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import Foundation
import SwiftData

@Model
final class MeritBadge {
    @Attribute(.unique) var id: UUID
    var name: String
    var badgeDescription: String
    var category: String
    var isEagleRequired: Bool
    var requirements: [String]
    var resourceURL: String?
    var completedRequirements: [Bool]
    var dateStarted: Date?
    var dateCompleted: Date?
    var isCompleted: Bool {
        dateCompleted != nil
    }
    
    init(name: String, 
         badgeDescription: String, 
         category: String, 
         isEagleRequired: Bool = false,
         requirements: [String] = [],
         resourceURL: String? = nil) {
        self.id = UUID()
        self.name = name
        self.badgeDescription = badgeDescription
        self.category = category
        self.isEagleRequired = isEagleRequired
        self.requirements = requirements
        self.resourceURL = resourceURL
        self.completedRequirements = Array(repeating: false, count: requirements.count)
        self.dateStarted = nil
        self.dateCompleted = nil
    }
    
    /// Progress as a percentage (0.0 to 1.0)
    var progress: Double {
        guard !requirements.isEmpty else { return 0.0 }
        let completed = completedRequirements.filter { $0 }.count
        return Double(completed) / Double(requirements.count)
    }
    
    /// Toggle a requirement's completion status
    func toggleRequirement(at index: Int) {
        guard index >= 0 && index < completedRequirements.count else { return }
        completedRequirements[index].toggle()
        
        // Update dates
        if dateStarted == nil {
            dateStarted = Date()
        }
        
        // Check if all requirements are complete
        if completedRequirements.allSatisfy({ $0 }) {
            dateCompleted = Date()
        } else {
            dateCompleted = nil
        }
    }
    
    /// Mark badge as started
    func markAsStarted() {
        if dateStarted == nil {
            dateStarted = Date()
        }
    }
    
    /// Reset all progress
    func resetProgress() {
        completedRequirements = Array(repeating: false, count: requirements.count)
        dateStarted = nil
        dateCompleted = nil
    }
}
