//
//  PaywallView.swift
//  Sam's Games
//
//  Premium subscription paywall
//

import SwiftUI

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showTerms = false
    @State private var showPrivacy = false

    var body: some View {
        NavigationView {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }

                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("Sam's Games")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        Text("Premium")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 20)

                    // Features
                    VStack(spacing: 20) {
                        FeatureRow(icon: "calendar", title: "Unlimited Archive Access", description: "Play any puzzle from any date")
                        FeatureRow(icon: "chart.bar.fill", title: "Extended Statistics", description: "Track your progress over time")
                        FeatureRow(icon: "sparkles", title: "Ad-Free Experience", description: "Enjoy uninterrupted gameplay")
                        FeatureRow(icon: "star.fill", title: "Future Features", description: "Get early access to new games")
                    }
                    .padding(.horizontal)

                    // Subscription Details (Required by Apple)
                    VStack(spacing: 12) {
                        Text("Sam's Games Premium")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        Text("Monthly Subscription")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text("\(subscriptionManager.subscriptionPrice) per month")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Cancel anytime")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 10)

                    // Subscribe button
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    } else {
                        Button(action: {
                            Task {
                                await subscriptionManager.purchase()
                            }
                        }) {
                            Text("Start Premium")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.purple)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)
                    }

                    // Error message
                    if let error = subscriptionManager.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                            .padding(.horizontal)
                    }

                    // Restore button
                    Button(action: {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .underline()
                    }
                    .padding(.top, 10)

                    // Legal text (Required by Apple)
                    VStack(spacing: 8) {
                        Text("A \(subscriptionManager.subscriptionPrice) purchase will be applied to your iTunes account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime through your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 20) {
                            Button(action: { showTerms = true }) {
                                Text("Terms of Use")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                                    .underline()
                            }

                            Button(action: { showPrivacy = true }) {
                                Text("Privacy Policy")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                                    .underline()
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        }
        .sheet(isPresented: $showTerms) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.yellow)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    PaywallView()
}
