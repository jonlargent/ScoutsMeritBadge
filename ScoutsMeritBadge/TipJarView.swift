//
//  TipJarView.swift
//  ScoutsMeritBadge
//
//  An optional tip jar. The app is free and ad-free — tips are entirely
//  optional and unlock nothing.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = TipStore()

    var body: some View {
        NavigationStack {
            ZStack {
                ScoutTheme.categoryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        messaging

                        tipList
                    }
                    .padding()
                }
            }
            .navigationTitle("Support the App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ScoutTheme.headerBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(ScoutTheme.bsaBlue)
                }
            }
            .task {
                await store.loadProducts()
            }
            .alert("Thank you!", isPresented: $store.didCompletePurchase) {
                Button("You're welcome!") { }
            } message: {
                Text("Your support helps keep this app free and ad-free for every Scout.")
            }
            .alert(
                "Oops",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )
            ) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "tent.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(ScoutTheme.scoutGradient)
                .frame(width: 70, height: 70)
                .shadow(color: ScoutTheme.bsaRed.opacity(0.3), radius: 8, y: 4)

            Text("This app is free and always ad-free.")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(ScoutTheme.bsaBlue)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var messaging: some View {
        Text("If it's been useful, you can leave a tip to support development. It's completely optional — tips don't unlock anything.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var tipList: some View {
        if store.isLoading {
            ProgressView()
                .padding(.top, 20)
        } else if store.products.isEmpty {
            Text("Tips aren't available right now. Please check back later.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        } else {
            VStack(spacing: 12) {
                ForEach(store.products, id: \.id) { product in
                    TipRow(product: product) {
                        await store.purchase(product)
                    }
                }
            }
        }
    }
}

// MARK: - Tip Row

private struct TipRow: View {
    let product: Product
    let onPurchase: () async -> Void

    @State private var isPurchasing = false

    private var symbol: String {
        TipProduct(rawValue: product.id)?.symbol ?? "heart.fill"
    }

    var body: some View {
        Button {
            Task {
                isPurchasing = true
                await onPurchase()
                isPurchasing = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(ScoutTheme.bsaRed)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(ScoutTheme.bsaBlue)
                    if !product.description.isEmpty {
                        Text(product.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .font(.headline)
                        .foregroundStyle(ScoutTheme.bsaGreen)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: ScoutTheme.bsaBlue.opacity(0.08), radius: 6, y: 3)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}

#Preview {
    TipJarView()
}
