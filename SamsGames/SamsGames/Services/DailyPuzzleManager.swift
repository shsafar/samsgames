//
//  DailyPuzzleManager.swift
//  Sam's Games
//
//  Manages daily puzzle logic with user timezone
//

import Foundation
import Combine

enum GameType: String, CaseIterable, Codable, Identifiable {
    case xNumbers = "X-Numbers"
    case wordInShapes = "Word In Shapes"

    var id: String { self.rawValue }

    // Custom app icon from Assets (if available)
    var customIcon: String? {
        switch self {
        case .xNumbers: return "xnumbersicon"
        case .wordInShapes: return "WordInShapesIcon"
        }
    }

    // SF Symbol fallback
    var icon: String {
        switch self {
        case .xNumbers: return "number.square.fill"
        case .wordInShapes: return "textformat.abc"
        }
    }

    var description: String {
        switch self {
        case .xNumbers: return "Solve the cross-sum puzzle"
        case .wordInShapes: return "Find words hidden in shapes"
        }
    }
}

class DailyPuzzleManager: ObservableObject {
    @Published var currentDate: Date
    @Published var completedToday: Set<GameType> = []

    private let calendar = Calendar.current
    private let userDefaults = UserDefaults.standard
    private let completedTodayKey = "completedToday"
    private let lastCheckDateKey = "lastCheckDate"

    init() {
        self.currentDate = Date()
        loadCompletedToday()
        checkForNewDay()
    }

    // MARK: - Daily Puzzle Logic

    /// Get today's date string (user timezone)
    func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: currentDate)
    }

    /// Get seed for today's puzzle (same for all users in same timezone on same day)
    func getSeedForToday() -> Int {
        let dateString = getTodayString()
        return dateString.hash
    }

    /// Get seed for specific date
    func getSeedForDate(_ date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: date)
        return dateString.hash
    }

    /// Get X-Numbers level based on day of week
    /// Monday/Wed/Fri: L1 (Easy), Tue/Thu: L2 (Medium), Sat/Sun: L3 (Hard)
    func getLevelForDate(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 1: return 3  // Sunday: L3
        case 2: return 1  // Monday: L1
        case 3: return 2  // Tuesday: L2
        case 4: return 1  // Wednesday: L1
        case 5: return 2  // Thursday: L2
        case 6: return 1  // Friday: L1
        case 7: return 3  // Saturday: L3
        default: return 1
        }
    }

    /// Get today's X-Numbers level
    func getTodayLevel() -> Int {
        return getLevelForDate(currentDate)
    }

    /// Get difficulty name for level
    func getDifficultyName(for level: Int) -> String {
        switch level {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Easy"
        }
    }

    /// Get difficulty emoji for level
    func getDifficultyEmoji(for level: Int) -> String {
        switch level {
        case 1: return "🟢"
        case 2: return "🟡"
        case 3: return "🔴"
        default: return "🟢"
        }
    }

    /// Check if a game was completed today
    func isCompletedToday(_ gameType: GameType) -> Bool {
        return completedToday.contains(gameType)
    }

    /// Mark a game as completed for today
    func markCompleted(_ gameType: GameType) {
        completedToday.insert(gameType)
        saveCompletedToday()
    }

    /// Get available dates (last 30 days for archive, excluding today)
    func getAvailableDates(count: Int = 30) -> [Date] {
        var dates: [Date] = []
        // Start from yesterday (i=1) to exclude today's date
        for i in 1..<(count + 1) {
            if let date = calendar.date(byAdding: .day, value: -i, to: currentDate) {
                dates.append(date)
            }
        }
        return dates
    }

    // MARK: - Persistence

    private func loadCompletedToday() {
        if let data = userDefaults.data(forKey: completedTodayKey),
           let decoded = try? JSONDecoder().decode(Set<GameType>.self, from: data) {
            self.completedToday = decoded
        }
    }

    private func saveCompletedToday() {
        if let encoded = try? JSONEncoder().encode(completedToday) {
            userDefaults.set(encoded, forKey: completedTodayKey)
        }
    }

    /// Check if it's a new day, reset completed if so
    private func checkForNewDay() {
        let todayString = getTodayString()
        let lastCheckString = userDefaults.string(forKey: lastCheckDateKey)

        if todayString != lastCheckString {
            // New day! Reset completed
            completedToday.removeAll()
            saveCompletedToday()
            userDefaults.set(todayString, forKey: lastCheckDateKey)
        }
    }
}
