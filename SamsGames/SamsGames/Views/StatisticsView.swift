//
//  StatisticsView.swift
//  Sam's Games
//
//  View showing statistics and streaks for all games
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) var dismiss

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
