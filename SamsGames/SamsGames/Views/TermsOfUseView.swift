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

                    SectionView(title: "Daily Puzzles") {
                        Text("The daily puzzle system provides one puzzle per game per day. Puzzles are generated algorithmically and are the same for all users on the same day.")
                    }

                    SectionView(title: "User Conduct") {
                        Text("Sam's Games is designed for fair play and personal enjoyment:")
                        BulletPoint("Game progress is stored locally on your device")
                        BulletPoint("Statistics and streaks are for personal tracking only")
                        BulletPoint("No competitive or multiplayer features exist")
                    }

                    SectionView(title: "Intellectual Property") {
                        Text("Sam's Games, including all game content, designs, and algorithms, is owned by zYouSoft, Inc. Game concepts may be inspired by classic puzzle types.")
                    }

                    SectionView(title: "Disclaimer") {
                        Text("Sam's Games is provided \"as is\" without warranties of any kind. We do not guarantee uninterrupted or error-free operation.")
                    }

                    SectionView(title: "Limitation of Liability") {
                        Text("zYouSoft, Inc shall not be liable for any damages arising from the use or inability to use the app.")
                    }

                    SectionView(title: "Changes to Terms") {
                        Text("We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of modified terms.")
                    }

                    SectionView(title: "Contact") {
                        Text("Questions about these Terms of Use? Contact us through the Support & Contact section.")
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

#Preview {
    TermsOfUseView()
}
