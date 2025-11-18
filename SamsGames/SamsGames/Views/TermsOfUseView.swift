//
//  TermsOfUseView.swift
//  Sam's Games
//
//  Terms of Use information
//

import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Use")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom, 10)

                    Text("Last updated: November 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    SectionView(title: "Acceptance of Terms") {
                        Text("By downloading and using Sam's Games, you agree to these Terms of Use. If you do not agree, please do not use the app.")
                    }

                    SectionView(title: "License") {
                        Text("Sam's Games grants you a personal, non-transferable, non-exclusive license to use the app for personal entertainment purposes.")
                        BulletPoint("You may not copy, modify, or distribute the app")
                        BulletPoint("You may not reverse engineer or attempt to extract source code")
                        BulletPoint("All intellectual property rights belong to zYouSoft, Inc")
                    }

                    SectionView(title: "Premium Subscription") {
                        Text("Sam's Games offers a monthly subscription for premium features:")
                        BulletPoint("Price: $4.99 per month (USD)")
                        BulletPoint("Benefits: Unlimited archive access, extended statistics, and ad-free experience")
                        BulletPoint("Free tier includes daily puzzles for all games")
                        BulletPoint("Payment is charged to your iTunes Account at confirmation of purchase")
                        BulletPoint("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period")
                        BulletPoint("Your account will be charged for renewal within 24 hours prior to the end of the current period")
                        BulletPoint("You can manage and cancel subscriptions in Settings → [Your Name] → Subscriptions")
                        BulletPoint("No refunds for partial subscription periods")
                    }

                    SectionView(title: "Cancellation & Refunds") {
                        Text("Subscription Cancellation:")
                        BulletPoint("Cancel anytime through iOS Settings → [Your Name] → Subscriptions")
                        BulletPoint("Cancellation takes effect at the end of the current billing period")
                        BulletPoint("You will retain premium access until the end of the paid period")
                        BulletPoint("No partial refunds for unused time within a billing period")

                        Text("\n\nRefund Requests:")
                            .font(.system(size: 16, weight: .semibold))
                        BulletPoint("All payments are processed by Apple")
                        BulletPoint("Refund requests must be submitted through Apple")
                        BulletPoint("Go to reportaproblem.apple.com or contact Apple Support")
                        BulletPoint("Refunds are subject to Apple's refund policy")
                        BulletPoint("We do not have access to process refunds directly")

                        Text("\n\nApple's Standard Refund Policy applies:")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        BulletPoint("Refunds typically granted within 48 hours of purchase if requested promptly")
                        BulletPoint("Accidental purchases may be refunded")
                        BulletPoint("Refunds are at Apple's discretion")
                    }

                    SectionView(title: "Free Trial (if offered)") {
                        Text("If a free trial is offered:")
                        BulletPoint("Trial period will be clearly displayed before purchase")
                        BulletPoint("You will be charged the full subscription price after trial ends unless cancelled")
                        BulletPoint("Cancel during the trial period to avoid charges")
                        BulletPoint("Cancellation must occur at least 24 hours before trial ends")
                    }

                    SectionView(title: "Daily Puzzles") {
                        Text("The daily puzzle system provides one puzzle per game per day. Puzzles are generated algorithmically and are the same for all users on the same date. Archive access (past puzzles) requires a Premium subscription.")
                    }

                    SectionView(title: "User Conduct") {
                        Text("Sam's Games is designed for fair play and personal enjoyment:")
                        BulletPoint("Game progress is stored locally on your device")
                        BulletPoint("Statistics and streaks are for personal tracking only")
                        BulletPoint("No competitive or multiplayer features exist")
                        BulletPoint("Do not use the app for illegal or unauthorized purposes")
                    }

                    SectionView(title: "Intellectual Property") {
                        Text("Sam's Games, including all game content, designs, and algorithms, is owned by zYouSoft, Inc. Game concepts may be inspired by classic puzzle types. You may not:")
                        BulletPoint("Copy, modify, or distribute the app or its content")
                        BulletPoint("Reverse engineer or extract source code")
                        BulletPoint("Use the app's content for commercial purposes")
                        BulletPoint("Remove copyright or trademark notices")
                    }

                    SectionView(title: "App Availability") {
                        Text("We reserve the right to:")
                        BulletPoint("Modify, suspend, or discontinue the app or any features at any time")
                        BulletPoint("Change subscription pricing with 30 days notice")
                        BulletPoint("Update daily puzzle algorithms or content")
                        BulletPoint("Active subscribers will be notified of significant changes")
                    }

                    SectionView(title: "Disclaimer of Warranties") {
                        Text("Sam's Games is provided \"AS IS\" and \"AS AVAILABLE\" without warranties of any kind, either express or implied, including but not limited to:")
                        BulletPoint("Merchantability or fitness for a particular purpose")
                        BulletPoint("Uninterrupted or error-free operation")
                        BulletPoint("Accuracy or reliability of content")
                        BulletPoint("Freedom from viruses or harmful components")
                    }

                    SectionView(title: "Limitation of Liability") {
                        Text("To the maximum extent permitted by law, zYouSoft, Inc shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues arising from:")
                        BulletPoint("Use or inability to use the app")
                        BulletPoint("Loss of data or game progress")
                        BulletPoint("Subscription renewal charges")
                        BulletPoint("Unauthorized access to your device")

                        Text("\n\nOur total liability shall not exceed the amount you paid for the subscription in the 12 months preceding the claim.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    SectionView(title: "Governing Law") {
                        Text("These Terms shall be governed by the laws of the United States and the state where zYouSoft, Inc is registered, without regard to conflict of law principles.")
                    }

                    SectionView(title: "Changes to Terms") {
                        Text("We reserve the right to modify these Terms of Use at any time. Material changes will be communicated through:")
                        BulletPoint("In-app notification")
                        BulletPoint("Updated \"Last updated\" date")
                        BulletPoint("Continued use constitutes acceptance of modified terms")
                        BulletPoint("If you disagree with changes, cancel your subscription and stop using the app")
                    }

                    SectionView(title: "Contact & Support") {
                        Text("For questions about these Terms of Use, subscription issues, or technical support:")
                        BulletPoint("Use the Support & Contact section in the app")
                        BulletPoint("For refund requests: contact Apple Support or visit reportaproblem.apple.com")
                        BulletPoint("Response time: typically within 48-72 hours")
                    }

                    SectionView(title: "Severability") {
                        Text("If any provision of these Terms is found to be unenforceable, the remaining provisions will continue in full force and effect.")
                    }

                    Text("By using Sam's Games, you acknowledge that you have read, understood, and agree to be bound by these Terms of Use and our Privacy Policy.")
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

#Preview {
    TermsOfUseView()
}
