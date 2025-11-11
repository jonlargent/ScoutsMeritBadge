//
//  ImportBadgesView.swift
//  ScoutsMeritBadge
//
//  Created by Jon Largent on 11/11/25.
//

import SwiftUI
import SwiftData

struct ImportBadgesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var importService = MeritBadgeImportService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding()
                
                Text("Import Merit Badges")
                    .font(.title)
                    .bold()
                
                Text("This will scrape merit badge information from Scouting.org. This process may take several minutes.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                if importService.isImporting {
                    VStack(spacing: 12) {
                        ProgressView(value: importService.progress) {
                            Text(importService.statusMessage)
                                .font(.caption)
                        }
                        .padding(.horizontal, 40)
                        
                        Text("\(Int(importService.progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        Task {
                            await importService.importAllBadges(into: modelContext)
                        }
                    } label: {
                        Label("Start Import", systemImage: "arrow.down.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 40)
                }
                
                if let errorMessage = importService.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("This is experimental", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    
                    Text("Web scraping is fragile and may break if the website changes. Consider using the sample data loader instead.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .disabled(importService.isImporting)
                }
            }
        }
    }
}

#Preview {
    ImportBadgesView()
}
