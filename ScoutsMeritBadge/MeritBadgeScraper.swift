//
//  MeritBadgeScraper.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import Foundation

/// A service that scrapes merit badge information from Scouting.org
/// Warning: This is fragile and will break if the website structure changes
actor MeritBadgeScraper {
    
    enum ScraperError: Error, LocalizedError {
        case invalidURL
        case networkError(Error)
        case parsingError
        case noData
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL provided"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .parsingError:
                return "Failed to parse website content"
            case .noData:
                return "No data received from server"
            }
        }
    }
    
    private let baseURL = "https://www.scouting.org/merit-badges/"
    
    /// Fetches the list of all merit badges from the main page
    func fetchAllMeritBadges() async throws -> [MeritBadgeData] {
        guard let url = URL(string: baseURL) else {
            throw ScraperError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ScraperError.networkError(URLError(.badServerResponse))
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScraperError.noData
        }
        
        return try parseMeritBadgeList(from: html)
    }
    
    /// Fetches detailed information about a specific merit badge
    func fetchMeritBadgeDetails(url: String) async throws -> MeritBadgeData {
        guard let requestURL = URL(string: url) else {
            throw ScraperError.invalidURL
        }
        
        // Add a small delay to be respectful of the server
        try await Task.sleep(for: .milliseconds(500))
        
        let (data, response) = try await URLSession.shared.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ScraperError.networkError(URLError(.badServerResponse))
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScraperError.noData
        }
        
        return try parseMeritBadgeDetail(from: html, url: url)
    }
    
    // MARK: - Private Parsing Methods
    
    private func parseMeritBadgeList(from html: String) throws -> [MeritBadgeData] {
        var badges: [MeritBadgeData] = []
        
        // The BSA website has merit badges listed with links
        // Looking for patterns like: <a href="/merit-badges/[name]/">Badge Name</a>
        // or <a href="https://www.scouting.org/merit-badges/[name]/">
        
        let patterns = [
            #"<a[^>]*href=\"(/merit-badges/[^/\"]+/)\"[^>]*>([^<]+)</a>"#,
            #"<a[^>]*href=\"(https://www\.scouting\.org/merit-badges/[^/\"]+/)\"[^>]*>([^<]+)</a>"#
        ]
        
        var allMatches: [(url: String, name: String)] = []
        
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                continue
            }
            
            let nsString = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    var urlPath = nsString.substring(with: match.range(at: 1))
                    let name = nsString.substring(with: match.range(at: 2))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: " Merit Badge", with: "")
                    
                    // Ensure we have a full URL
                    if !urlPath.hasPrefix("http") {
                        urlPath = "https://www.scouting.org\(urlPath)"
                    }
                    
                    allMatches.append((url: urlPath, name: name))
                }
            }
        }
        
        // Create badge data objects
        for match in allMatches {
            badges.append(MeritBadgeData(
                name: match.name,
                badgeDescription: "Description pending...",
                category: "Uncategorized",
                isEagleRequired: false,
                requirements: [],
                resourceURL: match.url
            ))
        }
        
        // Remove duplicates by URL
        var uniqueBadges: [String: MeritBadgeData] = [:]
        for badge in badges {
            if let url = badge.resourceURL {
                uniqueBadges[url] = badge
            }
        }
        
        let result = Array(uniqueBadges.values).sorted { $0.name < $1.name }
        
        // If we didn't find any badges with the regex, throw an error
        if result.isEmpty {
            throw ScraperError.parsingError
        }
        
        return result
    }
    
    private func parseMeritBadgeDetail(from html: String, url: String) throws -> MeritBadgeData {
        // Extract the badge name from the title or heading
        let name = extractName(from: html) ?? extractNameFromURL(url) ?? "Unknown Badge"
        let description = extractDescription(from: html) ?? "No description available"
        let requirements = extractRequirements(from: html)
        let category = extractCategory(from: html) ?? "General"
        let isEagleRequired = checkIfEagleRequired(html: html)
        
        return MeritBadgeData(
            name: name,
            badgeDescription: description,
            category: category,
            isEagleRequired: isEagleRequired,
            requirements: requirements,
            resourceURL: url
        )
    }
    
    private func extractNameFromURL(_ url: String) -> String? {
        // Extract name from URL like: https://www.scouting.org/merit-badges/animal-science/
        guard let urlComponents = URLComponents(string: url),
              let pathComponents = urlComponents.path.split(separator: "/").last else {
            return nil
        }
        
        // Convert "animal-science" to "Animal Science"
        return String(pathComponents)
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    private func extractName(from html: String) -> String? {
        // Look for h1 or title tags
        let patterns = [
            #"<h1[^>]*>([^<]+)</h1>"#,
            #"<title>([^<]+)</title>"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) {
                let nsString = html as NSString
                var name = nsString.substring(with: match.range(at: 1))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Clean up common suffixes
                name = name.replacingOccurrences(of: " Merit Badge", with: "")
                name = name.replacingOccurrences(of: " - Boy Scouts of America", with: "")
                
                return name
            }
        }
        
        return nil
    }
    
    private func extractDescription(from html: String) -> String? {
        // Look for meta description or first paragraph
        let patterns = [
            #"<meta name=\"description\" content=\"([^\"]+)\""#,
            #"<p[^>]*>([^<]+)</p>"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) {
                let nsString = html as NSString
                let description = nsString.substring(with: match.range(at: 1))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if description.count > 20 { // Make sure it's substantial
                    return description
                }
            }
        }
        
        return nil
    }
    
    private func extractRequirements(from html: String) -> [String] {
        var requirements: [String] = []
        
        // Look for ordered lists (ol) that typically contain requirements
        // BSA pages often have requirements in <ol> tags with <li> items
        let pattern = #"<li[^>]*>(.*?)</li>"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return []
        }
        
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            var requirement = nsString.substring(with: match.range(at: 1))
            
            // Strip all HTML tags
            requirement = stripHTMLTags(from: requirement)
            requirement = requirement.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Decode HTML entities
            requirement = decodeHTMLEntities(requirement)
            
            // Normalize whitespace (replace multiple spaces/newlines with single space)
            requirement = requirement.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            // Only include substantial requirements
            if requirement.count > 10 && !requirement.isEmpty {
                requirements.append(requirement)
            }
        }
        
        return requirements
    }
    
    private func stripHTMLTags(from text: String) -> String {
        var result = text
        
        // Remove script and style content
        result = result.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
        
        // Remove all HTML tags
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        return result
    }
    
    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        
        // Common HTML entities
        let entities: [String: String] = [
            "&quot;": "\"",
            "&apos;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&#39;": "'",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&lsquo;": "'",
            "&rsquo;": "'",
            "&mdash;": "—",
            "&ndash;": "–"
        ]
        
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement, options: .caseInsensitive)
        }
        
        // Decode numeric entities like &#123;
        let pattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = result as NSString
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Process in reverse to maintain indices
            for match in matches.reversed() {
                if let numberRange = Range(match.range(at: 1), in: result),
                   let number = Int(result[numberRange]),
                   let scalar = UnicodeScalar(number) {
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: String(Character(scalar)))
                }
            }
        }
        
        return result
    }
    
    private func extractCategory(from html: String) -> String? {
        // Try to find category information
        // This would depend on how the website structures its data
        
        let categories = [
            "Outdoor Skills", "STEM", "Health and Safety", "Citizenship",
            "Arts and Hobbies", "Business", "Nature", "Trades", "Sports and Fitness"
        ]
        
        for category in categories {
            if html.localizedCaseInsensitiveContains(category) {
                return category
            }
        }
        
        return "General"
    }
    
    private func checkIfEagleRequired(html: String) -> Bool {
        // Look for indicators that this is an Eagle-required badge
        let indicators = [
            "eagle required",
            "eagle-required",
            "required for eagle",
            "eagle rank requirement"
        ]
        
        let lowercasedHTML = html.lowercased()
        return indicators.contains { lowercasedHTML.contains($0) }
    }
}

// MARK: - Data Transfer Object

/// A simple struct for transferring scraped data before converting to SwiftData models
struct MeritBadgeData {
    let name: String
    let badgeDescription: String
    let category: String
    let isEagleRequired: Bool
    let requirements: [String]
    let resourceURL: String?
}
