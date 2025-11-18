//
//  StatisticsView.swift
//  Sam's Games
//
//  View showing statistics and streaks for all games
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var statisticsManager: StatisticsManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var titleTapCount = 0
    @State private var lastTapTime = Date()
    @State private var showTestModeAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(GameType.allCases, id: \.id) { gameType in
                    Section(header: Text(gameType.rawValue)) {
                        let stats = statisticsManager.getStatistics(for: gameType)

                        StatRow(label: "Games Completed", value: "\(stats.gamesPlayed)")
                        StatRow(
                            label: "Current Streak",
                            value: "\(stats.currentStreak) \(stats.currentStreak == 1 ? "day" : "days")",
                            highlight: stats.currentStreak > 0
                        )
                        StatRow(
                            label: "Longest Streak",
                            value: "\(stats.longestStreak) \(stats.longestStreak == 1 ? "day" : "days")"
                        )
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Statistics")
                        .font(.headline)
                        .onTapGesture {
                            handleTitleTap()
                        }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Test Mode Activated", isPresented: $showTestModeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Archive access unlocked for testing. This will persist until the app is reinstalled.")
            }
        }
    }

    private func handleTitleTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)

        // Reset counter if more than 2 seconds have passed since last tap
        if timeSinceLastTap > 2.0 {
            titleTapCount = 1
        } else {
            titleTapCount += 1
        }

        lastTapTime = now

        print("🔢 Title tap count: \(titleTapCount)/5")

        // Enable test mode after 5 taps
        if titleTapCount >= 5 {
            subscriptionManager.enableTestMode()
            showTestModeAlert = true
            titleTapCount = 0
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var highlight: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            HStack(spacing: 4) {
                if highlight {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                Text(value)
                    .font(.headline)
                    .foregroundColor(highlight ? .orange : .secondary)
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(StatisticsManager())
    }
}
