//
//  ScoutTheme.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI

/// Scout-themed colors and styling
struct ScoutTheme {
    
    // MARK: - Boy Scouts of America Official Colors
    
    /// BSA Red - Primary brand color
    static let bsaRed = Color(red: 206/255, green: 32/255, blue: 41/255)
    
    /// BSA Gold/Tan - Secondary brand color (uniform color)
    static let bsaTan = Color(red: 205/255, green: 170/255, blue: 125/255)
    
    /// BSA Dark Blue - Used in uniforms and badges
    static let bsaBlue = Color(red: 0/255, green: 46/255, blue: 93/255)
    
    /// BSA Dark Green - Forest/outdoor theme
    static let bsaGreen = Color(red: 0/255, green: 87/255, blue: 63/255)
    
    /// Scout Khaki - Uniform shirt color
    static let scoutKhaki = Color(red: 218/255, green: 187/255, blue: 142/255)
    
    // MARK: - Status Colors
    
    /// Color for completed badges
    static let completed = bsaGreen
    
    /// Color for in-progress badges
    static let inProgress = bsaBlue
    
    /// Color for not started badges
    static let notStarted = Color.gray
    
    /// Color for Eagle required indicators
    static let eagle = Color(red: 184/255, green: 134/255, blue: 11/255) // Dark gold
    
    /// Color for reset/warning actions
    static let warning = bsaRed
    
    // MARK: - Gradients
    
    static let scoutGradient = LinearGradient(
        colors: [bsaRed, bsaRed.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let outdoorGradient = LinearGradient(
        colors: [bsaGreen, bsaBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tanGradient = LinearGradient(
        colors: [scoutKhaki, bsaTan],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Background Colors
    
    static let headerBackground = bsaRed.opacity(0.1)
    static let statCardBackground = bsaTan.opacity(0.15)
    static let categoryBackground = bsaBlue.opacity(0.05)
}

// MARK: - Scout-themed View Modifiers

struct ScoutCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: ScoutTheme.bsaBlue.opacity(0.1), radius: 8, x: 0, y: 4)
            )
    }
}

struct ScoutBadgeStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
                    .overlay(
                        Capsule()
                            .strokeBorder(color.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct ScoutButtonStyle: ButtonStyle {
    let color: Color
    let isProminent: Bool
    
    init(color: Color = ScoutTheme.bsaRed, isProminent: Bool = false) {
        self.color = color
        self.isProminent = isProminent
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(isProminent ? .white : color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isProminent ? color : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color, lineWidth: isProminent ? 0 : 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func scoutCard() -> some View {
        modifier(ScoutCardStyle())
    }
    
    func scoutBadge(color: Color = ScoutTheme.bsaBlue) -> some View {
        modifier(ScoutBadgeStyle(color: color))
    }
}

// MARK: - Scout Fleur-de-lis Shape (BSA Symbol)

struct FleurDeLis: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Simplified fleur-de-lis shape
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
        
        // Center petal
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.5),
            control1: CGPoint(x: width * 0.3, y: height * 0.15),
            control2: CGPoint(x: width * 0.35, y: height * 0.4)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control1: CGPoint(x: width * 0.65, y: height * 0.4),
            control2: CGPoint(x: width * 0.7, y: height * 0.15)
        )
        
        // Left petal
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.5),
            control1: CGPoint(x: width * 0.35, y: height * 0.3),
            control2: CGPoint(x: width * 0.25, y: height * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.4, y: height * 0.5),
            control1: CGPoint(x: width * 0.2, y: height * 0.55),
            control2: CGPoint(x: width * 0.3, y: height * 0.55)
        )
        
        // Right petal
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.5),
            control1: CGPoint(x: width * 0.65, y: height * 0.3),
            control2: CGPoint(x: width * 0.75, y: height * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.6, y: height * 0.5),
            control1: CGPoint(x: width * 0.8, y: height * 0.55),
            control2: CGPoint(x: width * 0.7, y: height * 0.55)
        )
        
        // Bottom stem
        path.move(to: CGPoint(x: width * 0.45, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.8))
        path.addQuadCurve(
            to: CGPoint(x: width * 0.55, y: height * 0.8),
            control: CGPoint(x: width * 0.5, y: height * 0.85)
        )
        path.addLine(to: CGPoint(x: width * 0.55, y: height * 0.5))
        
        return path
    }
}

// MARK: - Merit Badge Shape

struct MeritBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let points = 12 // 12-pointed star for merit badge
        
        for i in 0..<points * 2 {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let length = i % 2 == 0 ? radius : radius * 0.6
            let x = center.x + length * cos(angle)
            let y = center.y + length * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Campfire Shape

struct CampfireShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Main flame
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.5),
            control1: CGPoint(x: width * 0.8, y: height * 0.2),
            control2: CGPoint(x: width * 0.8, y: height * 0.4)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.7),
            control1: CGPoint(x: width * 0.6, y: height * 0.6),
            control2: CGPoint(x: width * 0.5, y: height * 0.65)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.5),
            control1: CGPoint(x: width * 0.5, y: height * 0.65),
            control2: CGPoint(x: width * 0.4, y: height * 0.6)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.1),
            control1: CGPoint(x: width * 0.2, y: height * 0.4),
            control2: CGPoint(x: width * 0.2, y: height * 0.2)
        )
        
        return path
    }
}
