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

                    SectionView(title: "Information We Collect") {
                        Text("Sam's Games is designed with privacy in mind. We collect minimal information:")
                        BulletPoint("Game statistics and completion data (stored locally on your device)")
                        BulletPoint("No personal information is collected")
                        BulletPoint("No account creation required")
                        BulletPoint("No data is shared with third parties")
                    }

                    SectionView(title: "Data Storage") {
                        Text("All your game progress, statistics, and settings are stored locally on your device using iOS UserDefaults. This data never leaves your device and is not transmitted to any servers.")
                    }

                    SectionView(title: "Daily Puzzles") {
                        Text("Daily puzzles are generated using date-based algorithms. The same date produces the same puzzle for all users, but no user data is collected or compared.")
                    }

                    SectionView(title: "Children's Privacy") {
                        Text("Sam's Games is suitable for all ages. We do not knowingly collect any personal information from children or adults.")
                    }

                    SectionView(title: "Changes to This Policy") {
                        Text("We may update this privacy policy from time to time. Any changes will be reflected in the app with an updated date.")
                    }

                    SectionView(title: "Contact Us") {
                        Text("If you have any questions about this Privacy Policy, please contact us through the Support & Contact section in the app menu.")
                    }
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
