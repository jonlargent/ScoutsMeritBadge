//
//  TipStore.swift
//  ScoutsMeritBadge
//
//  Loads and purchases the optional tip jar in-app purchases via StoreKit 2.
//

import Foundation
import StoreKit

/// Product identifiers for the tip jar. These must match the consumable
/// in-app purchases configured in App Store Connect (and in a local
/// StoreKit configuration file for testing).
enum TipProduct: String, CaseIterable {
    case small = "com.largentlabs.ScoutsMeritBadge.tip.small"
    case medium = "com.largentlabs.ScoutsMeritBadge.tip.medium"
    case large = "com.largentlabs.ScoutsMeritBadge.tip.large"

    /// Friendly label shown when the product can't be loaded from the store.
    var fallbackLabel: String {
        switch self {
        case .small: return "Buy me a coffee"
        case .medium: return "Generous tip"
        case .large: return "Very generous tip"
        }
    }

    /// SF Symbol used to represent the tier.
    var symbol: String {
        switch self {
        case .small: return "cup.and.saucer.fill"
        case .medium: return "gift.fill"
        case .large: return "star.fill"
        }
    }
}

/// Observable store that loads tip products and handles purchases.
@MainActor
@Observable
final class TipStore {
    /// Tip products sorted from lowest to highest price.
    private(set) var products: [Product] = []

    /// Whether products are currently being loaded.
    private(set) var isLoading = false

    /// The most recent error message, if any.
    var errorMessage: String?

    /// Set to true briefly after a successful purchase to show a thank-you.
    var didCompletePurchase = false

    private let productIDs = TipProduct.allCases.map(\.rawValue)

    /// Loads the tip products from the App Store.
    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await Product.products(for: productIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Couldn't load tips. Please try again later."
        }
    }

    /// Purchases the given tip product.
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Tips are consumables — verify then immediately finish the
                // transaction. Nothing is unlocked in exchange for a tip.
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    didCompletePurchase = true
                } else {
                    errorMessage = "Couldn't verify your purchase."
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Your tip is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
