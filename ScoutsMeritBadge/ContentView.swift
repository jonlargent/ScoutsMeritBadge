//
//  ContentView.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meritBadges: [MeritBadge]
    
    @State private var searchText = ""
    @State private var showingEagleOnly = false
    @State private var hideCompleted = false
    @State private var showInProgressOnly = false
    @State private var showNotStartedOnly = false
    @State private var hasLoadedInitialData = false

    var filteredBadges: [MeritBadge] {
        var filtered = meritBadges
        
        // Filter by Eagle Required
        if showingEagleOnly {
            filtered = filtered.filter { $0.isEagleRequired }
        }
        
        // Filter by completion status
        if hideCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Filter by in progress only
        if showInProgressOnly {
            filtered = filtered.filter { $0.dateStarted != nil && !$0.isCompleted }
        }
        
        // Filter by not started only
        if showNotStartedOnly {
            filtered = filtered.filter { $0.dateStarted == nil && !$0.isCompleted }
        }
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.name < $1.name }
    }
    
    // Statistics
    var completedCount: Int {
        meritBadges.filter { $0.isCompleted }.count
    }
    
    var inProgressCount: Int {
        meritBadges.filter { $0.dateStarted != nil && !$0.isCompleted }.count
    }
    
    var notStartedCount: Int {
        meritBadges.filter { $0.dateStarted == nil && !$0.isCompleted }.count
    }
    
    var activeFiltersCount: Int {
        var count = 0
        if showingEagleOnly { count += 1 }
        if hideCompleted { count += 1 }
        if showInProgressOnly { count += 1 }
        if showNotStartedOnly { count += 1 }
        return count
    }

    var body: some View {
        NavigationSplitView {
            ZStack {
                // Scout-themed background
                ScoutTheme.categoryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Statistics Header with Scout styling
                    if !meritBadges.isEmpty {
                        VStack(spacing: 12) {
                            // Scout emblem header
                            HStack {
                                FleurDeLis()
                                    .fill(ScoutTheme.bsaRed)
                                    .frame(width: 30, height: 30)
                                
                                Text("My Progress")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(ScoutTheme.bsaBlue)
                                
                                Spacer()
                                
                                FleurDeLis()
                                    .fill(ScoutTheme.bsaRed)
                                    .frame(width: 30, height: 30)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            }
                            
                            // Statistics cards
                            HStack(spacing: 12) {
                                ScoutStatBadge(
                                    icon: "checkmark.seal.fill",
                                    color: ScoutTheme.completed,
                                    value: completedCount,
                                    label: "Completed"
                                )
                                
                                ScoutStatBadge(
                                    icon: "figure.hiking",
                                    color: ScoutTheme.inProgress,
                                    value: inProgressCount,
                                    label: "In Progress"
                                )
                                
                                ScoutStatBadge(
                                    icon: "star.circle.fill",
                                    color: ScoutTheme.eagle,
                                    value: meritBadges.filter { $0.isEagleRequired && $0.isCompleted }.count,
                                    label: "Eagle Done"
                                )
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ScoutTheme.statCardBackground)
                                .shadow(color: ScoutTheme.bsaBlue.opacity(0.1), radius: 8, y: 4)
                        )
                        .padding()
                    }
                    
                    // List
                    List {
                        ForEach(filteredBadges) { badge in
                            NavigationLink {
                                MeritBadgeDetailView(badge: badge)
                            } label: {
                                ScoutBadgeRow(badge: badge)
                            }
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if badge.isCompleted {
                                    Button {
                                        badge.resetProgress()
                                    } label: {
                                        Label("Reset", systemImage: "arrow.counterclockwise")
                                    }
                                    .tint(ScoutTheme.warning)
                                } else {
                                    Button {
                                        markBadgeComplete(badge)
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.seal.fill")
                                    }
                                    .tint(ScoutTheme.completed)
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                if !badge.isCompleted {
                                    if badge.dateStarted != nil {
                                        Button {
                                            markAsNotStarted(badge)
                                        } label: {
                                            Label("Not Started", systemImage: "xmark.circle")
                                        }
                                        .tint(ScoutTheme.notStarted)
                                    } else {
                                        Button {
                                            markAsInProgress(badge)
                                        } label: {
                                            Label("In Progress", systemImage: "figure.walk")
                                        }
                                        .tint(ScoutTheme.inProgress)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search merit badges")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("Status") {
                            Button {
                                showInProgressOnly.toggle()
                                if showInProgressOnly {
                                    showNotStartedOnly = false
                                    hideCompleted = false
                                }
                            } label: {
                                Label(
                                    showInProgressOnly ? "Show All" : "In Progress Only",
                                    systemImage: showInProgressOnly ? "figure.hiking" : "figure.walk"
                                )
                            }
                            
                            Button {
                                showNotStartedOnly.toggle()
                                if showNotStartedOnly {
                                    showInProgressOnly = false
                                    hideCompleted = false
                                }
                            } label: {
                                Label(
                                    showNotStartedOnly ? "Show All" : "Not Started Only",
                                    systemImage: showNotStartedOnly ? "circle.fill" : "circle"
                                )
                            }
                            
                            Button {
                                hideCompleted.toggle()
                                if hideCompleted {
                                    showInProgressOnly = false
                                    showNotStartedOnly = false
                                }
                            } label: {
                                Label(
                                    hideCompleted ? "Show Completed" : "Hide Completed",
                                    systemImage: hideCompleted ? "eye" : "eye.slash"
                                )
                            }
                        }
                        
                        Section("Badge Type") {
                            Button {
                                showingEagleOnly.toggle()
                            } label: {
                                Label(
                                    showingEagleOnly ? "Show All Badges" : "Eagle Required Only",
                                    systemImage: showingEagleOnly ? "star.circle.fill" : "star.circle"
                                )
                            }
                        }
                        
                        if showingEagleOnly || hideCompleted || showInProgressOnly || showNotStartedOnly {
                            Section {
                                Button {
                                    showingEagleOnly = false
                                    hideCompleted = false
                                    showInProgressOnly = false
                                    showNotStartedOnly = false
                                } label: {
                                    Label("Clear All Filters", systemImage: "xmark.circle")
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Image(systemName: activeFiltersCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .foregroundStyle(activeFiltersCount > 0 ? ScoutTheme.bsaRed : ScoutTheme.bsaBlue)
                            
                            if activeFiltersCount > 0 {
                                Text("\(activeFiltersCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(2)
                                    .background(Circle().fill(ScoutTheme.bsaRed))
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Statistics") {
                            Label("\(meritBadges.count) Total Badges", systemImage: "rosette")
                            Label("\(completedCount) Completed", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(ScoutTheme.completed)
                            Label("\(inProgressCount) In Progress", systemImage: "figure.hiking")
                                .foregroundStyle(ScoutTheme.inProgress)
                            Label("\(notStartedCount) Not Started", systemImage: "circle")
                                .foregroundStyle(ScoutTheme.notStarted)
                            if activeFiltersCount > 0 {
                                Label("\(filteredBadges.count) Shown (Filtered)", systemImage: "line.3.horizontal.decrease")
                                    .foregroundStyle(ScoutTheme.bsaBlue)
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            resetAllProgress()
                        } label: {
                            Label("Reset All Progress", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(ScoutTheme.bsaBlue)
                    }
                }
            }
            .navigationTitle("Merit Badges")
            .toolbarBackground(ScoutTheme.headerBackground, for: .navigationBar)
            .task {
                await loadInitialDataIfNeeded()
            }
        } detail: {
            VStack(spacing: 20) {
                FleurDeLis()
                    .fill(ScoutTheme.scoutGradient)
                    .frame(width: 80, height: 80)
                    .shadow(color: ScoutTheme.bsaRed.opacity(0.3), radius: 8, y: 4)
                
                VStack(spacing: 8) {
                    Text("Select a Merit Badge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(ScoutTheme.bsaBlue)
                    
                    Text("Track your progress on the trail to Eagle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ScoutTheme.categoryBackground)
        }
    }
    
    private func loadInitialDataIfNeeded() async {
        // Only load if database is empty and we haven't loaded before
        guard meritBadges.isEmpty && !hasLoadedInitialData else { return }
        
        hasLoadedInitialData = true
        
        do {
            let badges = try await MeritBadgeJSONLoader.loadFromBundle(filename: "merit_badges_lite")
            
            await MainActor.run {
                // Insert all badges into the database
                for badge in badges {
                    modelContext.insert(badge)
                }
                
                // Save the context
                try? modelContext.save()
            }
        } catch {
            print("Error loading badges from JSON: \(error)")
        }
    }
    
    private func markBadgeComplete(_ badge: MeritBadge) {
        // Mark all requirements as complete
        for index in badge.completedRequirements.indices {
            if !badge.completedRequirements[index] {
                badge.completedRequirements[index] = true
            }
        }
        
        // Set dates
        if badge.dateStarted == nil {
            badge.dateStarted = Date()
        }
        badge.dateCompleted = Date()
        
        try? modelContext.save()
    }
    
    private func markAsInProgress(_ badge: MeritBadge) {
        badge.markAsStarted()
        try? modelContext.save()
    }
    
    private func markAsNotStarted(_ badge: MeritBadge) {
        badge.dateStarted = nil
        badge.dateCompleted = nil
        // Keep any checked requirements but clear the start date
        try? modelContext.save()
    }
    
    private func resetAllProgress() {
        for badge in meritBadges {
            badge.resetProgress()
        }
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct ScoutBadgeRow: View {
    let badge: MeritBadge
    
    var statusColor: Color {
        if badge.isCompleted {
            return ScoutTheme.completed
        } else if badge.dateStarted != nil {
            return ScoutTheme.inProgress
        } else {
            return ScoutTheme.notStarted
        }
    }
    
    var statusText: String? {
        if let dateCompleted = badge.dateCompleted {
            return "Completed \(dateCompleted.formatted(date: .abbreviated, time: .omitted))"
        } else if let dateStarted = badge.dateStarted {
            if badge.progress > 0 {
                return "In Progress - \(Int(badge.progress * 100))% complete"
            } else {
                return "Started \(dateStarted.formatted(date: .abbreviated, time: .omitted))"
            }
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Merit badge shaped completion indicator
            ZStack {
                MeritBadgeShape()
                    .fill(
                        badge.isCompleted 
                            ? ScoutTheme.completed.opacity(0.15)
                            : badge.dateStarted != nil 
                                ? ScoutTheme.inProgress.opacity(0.1) 
                                : ScoutTheme.notStarted.opacity(0.05)
                    )
                    .frame(width: 50, height: 50)
                
                if badge.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(ScoutTheme.completed)
                        .font(.title2)
                } else if badge.dateStarted != nil {
                    if badge.progress > 0 {
                        ZStack {
                            Circle()
                                .stroke(ScoutTheme.notStarted.opacity(0.3), lineWidth: 2)
                            
                            Circle()
                                .trim(from: 0, to: badge.progress)
                                .stroke(ScoutTheme.inProgress, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(badge.progress * 100))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(ScoutTheme.inProgress)
                        }
                        .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "figure.hiking")
                            .foregroundStyle(ScoutTheme.inProgress)
                            .font(.body)
                    }
                } else {
                    Circle()
                        .stroke(ScoutTheme.notStarted.opacity(0.3), lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
            }
            
            // Badge info
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 6) {
                    Text(badge.name)
                        .font(.headline)
                        .foregroundStyle(ScoutTheme.bsaBlue)
                    
                    if badge.isEagleRequired {
                        ZStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(ScoutTheme.eagle)
                                .font(.caption)
                            Image(systemName: "star")
                                .foregroundStyle(ScoutTheme.eagle.opacity(0.5))
                                .font(.caption2)
                        }
                    }
                }
                
                HStack(spacing: 4) {
                    Text(badge.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(ScoutTheme.scoutKhaki.opacity(0.2))
                        )
                    
                    if let status = statusText {
                        Text("•")
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: ScoutTheme.bsaBlue.opacity(0.05), radius: 4, y: 2)
        )
    }
}

struct ScoutStatBadge: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                MeritBadgeShape()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .shadow(color: color.opacity(0.2), radius: 4, y: 2)
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                    Text("\(value)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(color)
                }
            }
            
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(ScoutTheme.bsaBlue)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MeritBadge.self, inMemory: true)
}
