//
//  MeritBadgeDetailView.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI

struct MeritBadgeDetailView: View {
    @Bindable var badge: MeritBadge
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            ScoutTheme.categoryBackground
                .ignoresSafeArea()
            
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Scout styling
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(badge.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(ScoutTheme.bsaBlue)
                            
                            Text(badge.category)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(ScoutTheme.scoutKhaki.opacity(0.3))
                                )
                        }
                        
                        Spacer()
                        
                        if badge.isEagleRequired {
                            VStack(spacing: 4) {
                                ZStack {
                                    MeritBadgeShape()
                                        .fill(ScoutTheme.eagle.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                        .shadow(color: ScoutTheme.eagle.opacity(0.3), radius: 4, y: 2)
                                    
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(ScoutTheme.eagle)
                                        .font(.title2)
                                }
                                Text("Eagle\nRequired")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(ScoutTheme.eagle)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    
                    // Progress indicator
                    if badge.progress > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "figure.hiking")
                                    .foregroundStyle(ScoutTheme.inProgress)
                                Text("Progress: \(Int(badge.progress * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(ScoutTheme.inProgress)
                                
                                Spacer()
                                
                                if badge.isCompleted {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(ScoutTheme.completed)
                                        Text("Complete!")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(ScoutTheme.completed)
                                    }
                                }
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ScoutTheme.notStarted.opacity(0.15))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: badge.isCompleted 
                                                    ? [ScoutTheme.completed, ScoutTheme.completed.opacity(0.8)]
                                                    : [ScoutTheme.inProgress, ScoutTheme.inProgress.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * badge.progress, height: 12)
                                        .shadow(color: badge.isCompleted ? ScoutTheme.completed.opacity(0.3) : ScoutTheme.inProgress.opacity(0.3), radius: 4, y: 2)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ScoutTheme.statCardBackground)
                        )
                    }
                    
                    // Dates with Scout icons
                    if let startDate = badge.dateStarted {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(ScoutTheme.inProgress)
                            Text("Started: \(startDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let completedDate = badge.dateCompleted {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(ScoutTheme.eagle)
                            Text("Completed: \(completedDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(ScoutTheme.completed)
                        }
                    }
                    
                    // Quick action buttons with Scout styling
                    if !badge.isCompleted {
                        HStack(spacing: 12) {
                            if badge.dateStarted == nil {
                                Button {
                                    badge.markAsStarted()
                                } label: {
                                    Label("Mark In Progress", systemImage: "figure.walk")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(ScoutButtonStyle(color: ScoutTheme.inProgress, isProminent: false))
                            }
                            
                            Button {
                                markAllComplete()
                            } label: {
                                Label("Mark Complete", systemImage: "checkmark.seal.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ScoutButtonStyle(color: ScoutTheme.completed, isProminent: true))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: ScoutTheme.bsaBlue.opacity(0.1), radius: 8, y: 4)
                )
                .padding(.horizontal)
                
                Divider()
                
                // Description with Scout styling
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        FleurDeLis()
                            .fill(ScoutTheme.bsaRed)
                            .frame(width: 20, height: 20)
                        Text("About This Badge")
                            .font(.headline)
                            .foregroundStyle(ScoutTheme.bsaBlue)
                    }
                    
                    Text(badge.badgeDescription)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ScoutTheme.statCardBackground)
                        )
                }
                .padding(.horizontal)
                
                // Requirements with checkboxes and Scout styling
                if !badge.requirements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .foregroundStyle(ScoutTheme.bsaBlue)
                                Text("Requirements")
                                    .font(.headline)
                                    .foregroundStyle(ScoutTheme.bsaBlue)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingResetAlert = true
                            } label: {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                                    .font(.caption)
                                    .foregroundStyle(ScoutTheme.warning)
                            }
                        }
                        
                        VStack(spacing: 0) {
                            ForEach(Array(badge.requirements.enumerated()), id: \.offset) { index, requirement in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        badge.toggleRequirement(at: index)
                                    }
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(badge.completedRequirements[index] ? ScoutTheme.completed.opacity(0.15) : ScoutTheme.notStarted.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: badge.completedRequirements[index] ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(badge.completedRequirements[index] ? ScoutTheme.completed : ScoutTheme.notStarted)
                                                .font(.title3)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Requirement \(index + 1)")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(ScoutTheme.bsaBlue.opacity(0.7))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule()
                                                            .fill(ScoutTheme.scoutKhaki.opacity(0.2))
                                                    )
                                                
                                                if badge.completedRequirements[index] {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .foregroundStyle(ScoutTheme.completed)
                                                        .font(.caption2)
                                                }
                                            }
                                            
                                            Text(requirement)
                                                .font(.body)
                                                .foregroundStyle(.primary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(badge.completedRequirements[index] ? ScoutTheme.completed.opacity(0.05) : Color(.systemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(
                                                        badge.completedRequirements[index] ? ScoutTheme.completed.opacity(0.3) : ScoutTheme.notStarted.opacity(0.1),
                                                        lineWidth: badge.completedRequirements[index] ? 2 : 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                if index < badge.requirements.count - 1 {
                                    Divider()
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ScoutTheme.statCardBackground)
                            .shadow(color: ScoutTheme.bsaBlue.opacity(0.05), radius: 8, y: 4)
                    )
                    .padding(.horizontal)
                }
                
                // Link to official page with Scout styling
                if let urlString = badge.resourceURL,
                   let url = URL(string: urlString) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "safari")
                            Text("View on Scouting.org")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ScoutTheme.scoutGradient)
                                .shadow(color: ScoutTheme.bsaRed.opacity(0.3), radius: 8, y: 4)
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                badge.resetProgress()
            }
        } message: {
            Text("Are you sure you want to reset all progress for this badge?")
        }
    }
    
    private func markAllComplete() {
        for index in badge.completedRequirements.indices {
            badge.completedRequirements[index] = true
        }
        
        if badge.dateStarted == nil {
            badge.dateStarted = Date()
        }
        badge.dateCompleted = Date()
    }
}

#Preview {
    NavigationStack {
        MeritBadgeDetailView(
            badge: MeritBadge(
                name: "First Aid",
                badgeDescription: "Learn essential first aid skills and emergency response.",
                category: "Health and Safety",
                isEagleRequired: true,
                requirements: [
                    "Demonstrate how to obtain consent before providing first aid",
                    "Explain the importance of assessing the scene",
                    "Describe the three hurry cases in first aid"
                ],
                resourceURL: "https://www.scouting.org/skills/merit-badges/first-aid/"
            )
        )
    }
}
