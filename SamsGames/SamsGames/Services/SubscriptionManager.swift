//
//  SubscriptionManager.swift
//  Sam's Games
//
//  Handles in-app subscription using StoreKit 2
//

import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isSubscribed: Bool = false
    @Published var subscriptionProduct: Product?
    @Published var isLoading: Bool = false
    @Published var purchaseError: String?
    @Published var testModeEnabled: Bool = UserDefaults.standard.bool(forKey: "testModeEnabled")

    // Product ID - must match App Store Connect
    private let monthlySubscriptionID = "com.samsgames.premium.monthly"

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [monthlySubscriptionID])
            subscriptionProduct = products.first
            print("✅ Loaded subscription product: \(subscriptionProduct?.displayName ?? "none")")
        } catch {
            print("❌ Failed to load products: \(error.localizedDescription)")
            purchaseError = "Failed to load subscription options"
        }
    }

    // MARK: - Purchase Subscription

    func purchase() async {
        guard let product = subscriptionProduct else {
            purchaseError = "Product not available"
            return
        }

        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)

                // Update subscription status
                await updateSubscriptionStatus()

                // Finish the transaction
                await transaction.finish()

                print("✅ Purchase successful!")

            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                purchaseError = nil

            case .pending:
                print("⏳ Purchase pending")
                purchaseError = "Purchase is pending approval"

            @unknown default:
                print("⚠️ Unknown purchase result")
                purchaseError = "Unknown error occurred"
            }
        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            purchaseError = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("✅ Purchases restored")
        } catch {
            print("❌ Failed to restore: \(error.localizedDescription)")
            purchaseError = "Failed to restore purchases"
        }
    }

    // MARK: - Check Subscription Status

    func updateSubscriptionStatus() async {
        var isActive = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if it's our subscription and it's not revoked
                if transaction.productID == monthlySubscriptionID {
                    isActive = true
                    break
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        isSubscribed = isActive
        print("📊 Subscription status: \(isSubscribed ? "ACTIVE" : "INACTIVE")")
    }

    // MARK: - Listen for Transaction Updates

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }

            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // Update subscription status on main actor
                    await self.updateSubscriptionStatus()

                    // Finish the transaction
                    await transaction.finish()
                } catch {
                    print("❌ Transaction update failed: \(error)")
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helper Properties

    var subscriptionPrice: String {
        subscriptionProduct?.displayPrice ?? "$4.99"
    }

    var formattedPrice: String {
        guard let product = subscriptionProduct else {
            return "$4.99/month"
        }
        return "\(product.displayPrice)/month"
    }

    // Check if user has premium access (either subscribed or test mode enabled)
    var isSubscribedOrTestMode: Bool {
        return isSubscribed || testModeEnabled
    }

    // MARK: - Test Mode

    func enableTestMode() {
        testModeEnabled = true
        UserDefaults.standard.set(true, forKey: "testModeEnabled")
        print("🔓 Test mode enabled - archive access unlocked")
    }

    func disableTestMode() {
        testModeEnabled = false
        UserDefaults.standard.set(false, forKey: "testModeEnabled")
        print("🔒 Test mode disabled")
    }
}

// MARK: - Store Error

enum StoreError: Error {
    case failedVerification
}
