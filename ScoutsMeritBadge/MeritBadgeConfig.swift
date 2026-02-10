//
//  MeritBadgeConfig.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/18/25.
//

import Foundation

/// Configuration for merit badge data sources
struct MeritBadgeConfig {
    
    /// Remote URL for fetching merit badge JSON data
    static let remoteJSONURL = "https://largentlabs.com/merit_badges_lite.json"
    
    /// Bundled JSON filename (used as fallback)
    static let bundledJSONFilename = "merit_badges_lite"
    
    /// Whether to use remote JSON (if false, only use bundled JSON)
    static let useRemoteJSON = true
}
