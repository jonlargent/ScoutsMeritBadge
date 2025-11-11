//
//  MeritBadgeJSONLoader.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import Foundation

/// Loads merit badge data from a bundled JSON file
struct MeritBadgeJSONLoader {
    
    struct JSONMeritBadge: Codable {
        let name: String
        let category: String
        let isEagleRequired: Bool
        let resourceURL: String?
        
        // Optional fields that might not be in all JSON files
        let description: String?
        let badgeDescription: String?
        let requirements: [String]?
    }
    
    enum LoaderError: Error, LocalizedError {
        case fileNotFound
        case invalidJSON
        case decodingError(Error)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "Merit badge data file not found"
            case .invalidJSON:
                return "Invalid JSON format"
            case .decodingError(let error):
                return "Failed to decode data: \(error.localizedDescription)"
            }
        }
    }
    
    /// Loads merit badges from a JSON file in the app bundle
    static func loadFromBundle(filename: String = "merit_badges") async throws -> [MeritBadge] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        
        do {
            let decoder = JSONDecoder()
            let jsonBadges = try decoder.decode([JSONMeritBadge].self, from: data)
            
            return jsonBadges.map { jsonBadge in
                MeritBadge(
                    name: jsonBadge.name,
                    badgeDescription: jsonBadge.description 
                        ?? jsonBadge.badgeDescription 
                        ?? "Visit the official Scouting.org page for more information.",
                    category: jsonBadge.category,
                    isEagleRequired: jsonBadge.isEagleRequired,
                    requirements: jsonBadge.requirements ?? [],
                    resourceURL: jsonBadge.resourceURL
                )
            }
        } catch {
            throw LoaderError.decodingError(error)
        }
    }
    
    /// Loads merit badges from JSON data
    static func loadFromData(_ data: Data) async throws -> [MeritBadge] {
        do {
            let decoder = JSONDecoder()
            let jsonBadges = try decoder.decode([JSONMeritBadge].self, from: data)
            
            return jsonBadges.map { jsonBadge in
                MeritBadge(
                    name: jsonBadge.name,
                    badgeDescription: jsonBadge.description 
                        ?? jsonBadge.badgeDescription 
                        ?? "Visit the official Scouting.org page for more information.",
                    category: jsonBadge.category,
                    isEagleRequired: jsonBadge.isEagleRequired,
                    requirements: jsonBadge.requirements ?? [],
                    resourceURL: jsonBadge.resourceURL
                )
            }
        } catch {
            throw LoaderError.decodingError(error)
        }
    }
    
    /// Returns comprehensive sample data with many common merit badges
    static func getComprehensiveSampleData() -> [MeritBadge] {
        return [
            // Eagle Required Merit Badges
            MeritBadge(
                name: "First Aid",
                badgeDescription: "Learn essential first aid skills and emergency response techniques to help others in need.",
                category: "Health and Safety",
                isEagleRequired: true,
                requirements: [
                    "Demonstrate how to obtain consent before providing first aid",
                    "Explain the importance of assessing the scene",
                    "Describe the three hurry cases in first aid"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/first-aid/"
            ),
            MeritBadge(
                name: "Camping",
                badgeDescription: "Learn camping skills, outdoor living, and leave no trace principles.",
                category: "Outdoor Skills",
                isEagleRequired: true,
                requirements: [
                    "Present yourself to your leader, properly equipped for an overnight campout",
                    "Explain the hazards you are most likely to encounter",
                    "Camp a total of at least 20 nights"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/camping/"
            ),
            MeritBadge(
                name: "Citizenship in the Community",
                badgeDescription: "Learn about your local community and how to be an engaged citizen.",
                category: "Citizenship",
                isEagleRequired: true,
                requirements: [
                    "Discuss the meaning of citizenship",
                    "Visit a local community leader",
                    "Attend a meeting of your city, town, or county council"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/citizenship-in-the-community/"
            ),
            MeritBadge(
                name: "Citizenship in the Nation",
                badgeDescription: "Learn about the U.S. government, Constitution, and national citizenship.",
                category: "Citizenship",
                isEagleRequired: true,
                requirements: [
                    "Explain the meaning of the Constitution",
                    "Name your senators and representative",
                    "Visit a federal building or historic site"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/citizenship-in-the-nation/"
            ),
            MeritBadge(
                name: "Citizenship in Society",
                badgeDescription: "Explore diversity, inclusion, and building a more just society.",
                category: "Citizenship",
                isEagleRequired: true,
                requirements: [
                    "Explain what it means to be a good citizen",
                    "Discuss diversity and inclusion",
                    "Learn about implicit bias"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/citizenship-in-society/"
            ),
            MeritBadge(
                name: "Citizenship in the World",
                badgeDescription: "Learn about world affairs, international organizations, and global citizenship.",
                category: "Citizenship",
                isEagleRequired: true,
                requirements: [
                    "Explain the meaning of world citizenship",
                    "Learn about international organizations",
                    "Discuss world events"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/citizenship-in-the-world/"
            ),
            MeritBadge(
                name: "Communication",
                badgeDescription: "Develop effective communication skills in various formats and situations.",
                category: "Skills",
                isEagleRequired: true,
                requirements: [
                    "Give a speech on a topic of your choice",
                    "Write a letter to the editor",
                    "Communicate effectively in different media"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/communication/"
            ),
            MeritBadge(
                name: "Cooking",
                badgeDescription: "Learn meal planning, food preparation, and nutrition.",
                category: "Outdoor Skills",
                isEagleRequired: true,
                requirements: [
                    "Plan menus for trail and camp cooking",
                    "Prepare meals outdoors",
                    "Discuss food safety and sanitation"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/cooking/"
            ),
            MeritBadge(
                name: "Cycling",
                badgeDescription: "Learn bicycle safety, maintenance, and take long-distance rides.",
                category: "Sports and Fitness",
                isEagleRequired: true,
                requirements: [
                    "Demonstrate bicycle safety",
                    "Adjust and repair your bicycle",
                    "Take several bicycle trips"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/cycling/"
            ),
            MeritBadge(
                name: "Emergency Preparedness",
                badgeDescription: "Learn how to prepare for and respond to emergencies and disasters.",
                category: "Health and Safety",
                isEagleRequired: true,
                requirements: [
                    "Earn the First Aid merit badge",
                    "Create an emergency action plan",
                    "Discuss emergency preparedness with your family"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/emergency-preparedness/"
            ),
            MeritBadge(
                name: "Environmental Science",
                badgeDescription: "Study ecology, pollution, and environmental conservation.",
                category: "Nature",
                isEagleRequired: true,
                requirements: [
                    "Conduct experiments on environmental topics",
                    "Study ecosystems",
                    "Complete environmental projects"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/environmental-science/"
            ),
            MeritBadge(
                name: "Family Life",
                badgeDescription: "Explore family relationships, responsibilities, and communication.",
                category: "Skills",
                isEagleRequired: true,
                requirements: [
                    "Discuss family dynamics",
                    "Create a family tree",
                    "Plan family activities"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/family-life/"
            ),
            MeritBadge(
                name: "Hiking",
                badgeDescription: "Learn hiking techniques, navigation, and take extensive hikes.",
                category: "Outdoor Skills",
                isEagleRequired: true,
                requirements: [
                    "Explain hiking safety",
                    "Demonstrate proper hiking techniques",
                    "Take five hikes totaling 50 miles"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/hiking/"
            ),
            MeritBadge(
                name: "Lifesaving",
                badgeDescription: "Learn water rescue techniques and lifesaving skills.",
                category: "Health and Safety",
                isEagleRequired: true,
                requirements: [
                    "Demonstrate rescue approaches",
                    "Perform water rescues",
                    "Earn the Swimming merit badge"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/lifesaving/"
            ),
            MeritBadge(
                name: "Personal Fitness",
                badgeDescription: "Develop a personal fitness program and maintain it for several months.",
                category: "Sports and Fitness",
                isEagleRequired: true,
                requirements: [
                    "Create a fitness plan",
                    "Exercise regularly for 12 weeks",
                    "Track your progress"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/personal-fitness/"
            ),
            MeritBadge(
                name: "Personal Management",
                badgeDescription: "Learn budgeting, financial planning, and time management.",
                category: "Business",
                isEagleRequired: true,
                requirements: [
                    "Create a budget",
                    "Track spending for 13 weeks",
                    "Learn about banking and investing"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/personal-management/"
            ),
            MeritBadge(
                name: "Sustainability",
                badgeDescription: "Learn about sustainable practices and environmental stewardship.",
                category: "Nature",
                isEagleRequired: true,
                requirements: [
                    "Explain sustainability",
                    "Complete a sustainability project",
                    "Reduce your environmental impact"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/sustainability/"
            ),
            MeritBadge(
                name: "Swimming",
                badgeDescription: "Learn swimming techniques, water safety, and endurance.",
                category: "Sports and Fitness",
                isEagleRequired: true,
                requirements: [
                    "Demonstrate swimming strokes",
                    "Swim long distances",
                    "Explain water safety"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/swimming/"
            ),
            
            // Non-Eagle Required Merit Badges
            MeritBadge(
                name: "Programming",
                badgeDescription: "Learn programming fundamentals and create software applications.",
                category: "STEM",
                isEagleRequired: false,
                requirements: [
                    "Show your counselor your current Cyber Chip",
                    "Give a brief history of programming",
                    "Describe three programming languages",
                    "Create working programs"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/programming/"
            ),
            MeritBadge(
                name: "Robotics",
                badgeDescription: "Design, build, and program robots.",
                category: "STEM",
                isEagleRequired: false,
                requirements: [
                    "Discuss robot safety",
                    "Build a robot",
                    "Program your robot to perform tasks"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/robotics/"
            ),
            MeritBadge(
                name: "Game Design",
                badgeDescription: "Learn about video game design and development.",
                category: "Arts and Hobbies",
                isEagleRequired: false,
                requirements: [
                    "Analyze existing games",
                    "Design your own game",
                    "Create a playable game prototype"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/game-design/"
            ),
            MeritBadge(
                name: "Photography",
                badgeDescription: "Learn photography techniques, composition, and digital editing.",
                category: "Arts and Hobbies",
                isEagleRequired: false,
                requirements: [
                    "Explain camera safety",
                    "Demonstrate camera controls",
                    "Create a photography portfolio"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/photography/"
            ),
            MeritBadge(
                name: "Art",
                badgeDescription: "Explore various art mediums and create original artwork.",
                category: "Arts and Hobbies",
                isEagleRequired: false,
                requirements: [
                    "Discuss art history",
                    "Create art in different mediums",
                    "Display your artwork"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/art/"
            ),
            MeritBadge(
                name: "Music",
                badgeDescription: "Learn about music theory, history, and performance.",
                category: "Arts and Hobbies",
                isEagleRequired: false,
                requirements: [
                    "Discuss music history",
                    "Demonstrate musical skills",
                    "Perform or compose music"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/music/"
            ),
            MeritBadge(
                name: "Aviation",
                badgeDescription: "Learn about aircraft, flight principles, and aviation careers.",
                category: "STEM",
                isEagleRequired: false,
                requirements: [
                    "Explain flight principles",
                    "Identify aircraft types",
                    "Visit an airport or aviation facility"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/aviation/"
            ),
            MeritBadge(
                name: "Space Exploration",
                badgeDescription: "Study space science, astronomy, and space exploration.",
                category: "STEM",
                isEagleRequired: false,
                requirements: [
                    "Discuss space history",
                    "Build and launch a model rocket",
                    "Visit a planetarium or observatory"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/space-exploration/"
            ),
            MeritBadge(
                name: "Astronomy",
                badgeDescription: "Learn about stars, planets, and celestial observation.",
                category: "Nature",
                isEagleRequired: false,
                requirements: [
                    "Identify constellations",
                    "Use a telescope",
                    "Track celestial objects"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/astronomy/"
            ),
            MeritBadge(
                name: "Geology",
                badgeDescription: "Study rocks, minerals, and Earth's geological processes.",
                category: "Nature",
                isEagleRequired: false,
                requirements: [
                    "Identify rocks and minerals",
                    "Explain geological processes",
                    "Visit geological sites"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/geology/"
            ),
            MeritBadge(
                name: "Fishing",
                badgeDescription: "Learn fishing techniques, equipment, and fish conservation.",
                category: "Outdoor Skills",
                isEagleRequired: false,
                requirements: [
                    "Demonstrate fishing knots",
                    "Identify fish species",
                    "Catch fish using different methods"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/fishing/"
            ),
            MeritBadge(
                name: "Archery",
                badgeDescription: "Learn safe archery techniques and marksmanship.",
                category: "Sports and Fitness",
                isEagleRequired: false,
                requirements: [
                    "Demonstrate archery safety",
                    "Identify archery equipment",
                    "Shoot arrows accurately"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/archery/"
            ),
            MeritBadge(
                name: "Woodworking",
                badgeDescription: "Learn woodworking techniques and create wooden projects.",
                category: "Trades",
                isEagleRequired: false,
                requirements: [
                    "Demonstrate tool safety",
                    "Complete woodworking projects",
                    "Finish and display your work"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/woodworking/"
            ),
            MeritBadge(
                name: "Entrepreneurship",
                badgeDescription: "Learn business planning and entrepreneurial skills.",
                category: "Business",
                isEagleRequired: false,
                requirements: [
                    "Create a business plan",
                    "Develop a product or service",
                    "Interview an entrepreneur"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/entrepreneurship/"
            ),
            MeritBadge(
                name: "Veterinary Medicine",
                badgeDescription: "Learn about animal health care and veterinary careers.",
                category: "Health and Safety",
                isEagleRequired: false,
                requirements: [
                    "Discuss animal health",
                    "Visit a veterinary facility",
                    "Learn about animal care"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/veterinary-medicine/"
            ),
            MeritBadge(
                name: "Coin Collecting",
                badgeDescription: "Learn about numismatics and start a coin collection.",
                category: "Arts and Hobbies",
                isEagleRequired: false,
                requirements: [
                    "Explain coin grading",
                    "Identify coin types",
                    "Create a coin collection"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/coin-collecting/"
            )
        ]
    }
}
