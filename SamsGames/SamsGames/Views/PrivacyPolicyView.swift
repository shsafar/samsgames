//
//  PrivacyPolicyView.swift
//  Sam's Games
//
//  Privacy Policy information
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 10)

                    Text("Last updated: November 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    SectionView(title: "Overview") {
                        Text("Sam's Games is committed to protecting your privacy. This policy explains how we handle your information in compliance with Apple's App Store guidelines and applicable privacy laws.")
                    }

                    SectionView(title: "Information We Collect") {
                        Text("Sam's Games is designed with privacy in mind. We collect minimal information:")
                        BulletPoint("Game statistics and completion data (stored locally on your device)")
                        BulletPoint("Purchase history for subscription management (handled by Apple)")
                        BulletPoint("No personal information is collected by us")
                        BulletPoint("No account creation required")
                        BulletPoint("No tracking or analytics")
                        BulletPoint("No advertising identifiers")
                    }

                    SectionView(title: "Data Storage") {
                        Text("All your game progress, statistics, and settings are stored locally on your device using iOS UserDefaults. This data:")
                        BulletPoint("Never leaves your device")
                        BulletPoint("Is not transmitted to any servers")
                        BulletPoint("Is not backed up to iCloud")
                        BulletPoint("Is deleted when you uninstall the app")
                    }

                    SectionView(title: "In-App Purchases & Subscriptions") {
                        Text("Subscription purchases are processed through Apple's App Store:")
                        BulletPoint("Your payment information is handled exclusively by Apple")
                        BulletPoint("We receive only subscription status (active/inactive) from Apple")
                        BulletPoint("We do not have access to your payment details")
                        BulletPoint("Purchase history is managed in your Apple ID settings")
                        BulletPoint("Subscriptions can be managed in Settings → [Your Name] → Subscriptions")
                    }

                    SectionView(title: "Daily Puzzles") {
                        Text("Daily puzzles are generated using date-based algorithms. The same date produces the same puzzle for all users, but no user data is collected or compared.")
                    }

                    SectionView(title: "Third-Party Services") {
                        Text("We do not use any third-party services, analytics, or tracking tools. The app operates entirely offline except for subscription verification with Apple's servers.")
                    }

                    SectionView(title: "Children's Privacy") {
                        Text("Sam's Games is suitable for all ages and complies with COPPA (Children's Online Privacy Protection Act). We do not knowingly collect any personal information from children or adults.")
                    }

                    SectionView(title: "Your Rights") {
                        Text("You have the right to:")
                        BulletPoint("Access your local game data (stored on your device)")
                        BulletPoint("Delete your data by uninstalling the app")
                        BulletPoint("Cancel your subscription at any time")
                        BulletPoint("Request support through the app's contact section")
                    }

                    SectionView(title: "Data Security") {
                        Text("Since all data is stored locally on your device, it is protected by your device's security features (passcode, Face ID, Touch ID). We do not transmit data over the internet, minimizing security risks.")
                    }

                    SectionView(title: "Changes to This Policy") {
                        Text("We may update this privacy policy from time to time. Any changes will be reflected in the app with an updated date. Continued use of the app constitutes acceptance of the updated policy.")
                    }

                    SectionView(title: "Contact Us") {
                        Text("If you have any questions about this Privacy Policy, please contact us through the Support & Contact section in the app menu.")
                    }

                    Text("By using Sam's Games, you agree to this Privacy Policy.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, 10)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            content
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 16, weight: .bold))
            Text(text)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
