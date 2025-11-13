//
//  StatisticsManager.swift
//  Sam's Games
//
//  Tracks completion streaks, history, and statistics
//

import Foundation
import Combine

struct GameCompletion: Codable {
    let gameType: GameType
    let date: Date
    let completed: Bool
}

struct GameStatistics: Codable {
    var gamesPlayed: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var completionHistory: [String: Bool] = [:] // "yyyy-MM-dd" : completed
}

class StatisticsManager: ObservableObject {
    @Published var statistics: [GameType: GameStatistics] = [:]

    private let userDefaults = UserDefaults.standard
    private let statisticsKey = "gameStatistics"
    private let calendar = Calendar.current

    init() {
        loadStatistics()
        // Initialize statistics for all game types
        for gameType in GameType.allCases {
            if statistics[gameType] == nil {
                statistics[gameType] = GameStatistics()
            }
        }
    }

    // MARK: - Statistics Updates

    /// Record a game completion
    func recordCompletion(_ gameType: GameType, date: Date = Date()) {
        guard var stats = statistics[gameType] else { return }

        let dateString = formatDate(date)

        // Only count if not already completed today
        if stats.completionHistory[dateString] != true {
            stats.gamesPlayed += 1
            stats.completionHistory[dateString] = true

            // Update streak
            updateStreak(for: gameType, stats: &stats, date: date)

            statistics[gameType] = stats
            saveStatistics()
        }
    }

    /// Get statistics for a game
    func getStatistics(for gameType: GameType) -> GameStatistics {
        return statistics[gameType] ?? GameStatistics()
    }

    /// Get current streak for a game
    func getCurrentStreak(for gameType: GameType) -> Int {
        return statistics[gameType]?.currentStreak ?? 0
    }

    /// Get longest streak for a game
    func getLongestStreak(for gameType: GameType) -> Int {
        return statistics[gameType]?.longestStreak ?? 0
    }

    /// Check if completed on a specific date
    func isCompleted(for gameType: GameType, on date: Date) -> Bool {
        let dateString = formatDate(date)
        return statistics[gameType]?.completionHistory[dateString] ?? false
    }

    // MARK: - Streak Calculation

    private func updateStreak(for gameType: GameType, stats: inout GameStatistics, date: Date) {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: date)!
        let yesterdayString = formatDate(yesterday)

        // Check if yesterday was completed
        if stats.completionHistory[yesterdayString] == true {
            // Continue streak
            stats.currentStreak += 1
        } else {
            // Start new streak
            stats.currentStreak = 1
        }

        // Update longest streak
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    // MARK: - Persistence

    private func loadStatistics() {
        if let data = userDefaults.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode([GameType: GameStatistics].self, from: data) {
            self.statistics = decoded
        }
    }

    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            userDefaults.set(encoded, forKey: statisticsKey)
        }
    }
}
