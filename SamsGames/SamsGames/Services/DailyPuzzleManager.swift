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
    case wordInShapes = "Words In Shapes"
    case jushBox = "JushBox"
    case doubleBubble = "Double Bubble"
    case diamondStack = "Diamond Stack"
    case hashtagWords = "Hashtag Words"
    case traceWiz = "TraceWiz"

    var id: String { self.rawValue }

    // Custom app icon from Assets (if available)
    var customIcon: String? {
        switch self {
        case .xNumbers: return "xnumbersicon"
        case .wordInShapes: return "WordInShapesIcon"
        case .jushBox: return "jushboxicon"
        case .doubleBubble: return "dbicon"
        case .diamondStack: return "diamondstackicon"
        case .hashtagWords: return "hashtagwordsicon"
        case .traceWiz: return "tracewizicon"
        }
    }

    // SF Symbol fallback
    var icon: String {
        switch self {
        case .xNumbers: return "number.square.fill"
        case .wordInShapes: return "textformat.abc"
        case .jushBox: return "cube.fill"
        case .doubleBubble: return "bubble.left.and.bubble.right.fill"
        case .diamondStack: return "triangle.fill"
        case .hashtagWords: return "number"
        case .traceWiz: return "scribble.variable"
        }
    }

    var description: String {
        switch self {
        case .xNumbers: return "Solve the cross-sum puzzle"
        case .wordInShapes: return "Find words hidden in shapes"
        case .jushBox: return "Sliding-stack puzzle"
        case .doubleBubble: return "Pop bubbles to form words"
        case .diamondStack: return "Fill circles to match triangle sums"
        case .hashtagWords: return "Fill the hashtag grid with words"
        case .traceWiz: return "Trace the line without crossing"
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
        return abs(dateString.hash)
    }

    /// Get seed for specific date
    func getSeedForDate(_ date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        let dateString = formatter.string(from: date)
        return abs(dateString.hash)
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

    /// Get JushBox level based on day of week
    /// Monday/Wed/Fri: L1 (Easy), Tue/Thu: L2 (Medium), Sat: L3 (Hard), Sun: L4 (Expert)
    func getJushBoxLevelForDate(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 1: return 4  // Sunday: L4 (Expert)
        case 2: return 1  // Monday: L1 (Easy)
        case 3: return 2  // Tuesday: L2 (Medium)
        case 4: return 1  // Wednesday: L1 (Easy)
        case 5: return 2  // Thursday: L2 (Medium)
        case 6: return 1  // Friday: L1 (Easy)
        case 7: return 3  // Saturday: L3 (Hard)
        default: return 1
        }
    }

    /// Get today's JushBox level
    func getTodayJushBoxLevel() -> Int {
        return getJushBoxLevelForDate(currentDate)
    }

    /// Get Diamond Stack level based on day of week
    /// Monday: L1, Tuesday: L2, Wednesday: L3, Thu-Sun: Random (1-3)
    func getDiamondStackLevelForDate(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 2: return 1  // Monday: L1 (Pyramid)
        case 3: return 2  // Tuesday: L2 (Diamond)
        case 4: return 3  // Wednesday: L3 (Hourglass)
        case 1, 5, 6, 7:  // Sun, Thu, Fri, Sat: Random 1-3
            // Use date seed for consistent random level
            let seed = getSeedForDate(date)
            return (seed % 3) + 1
        default: return 1
        }
    }

    /// Get today's Diamond Stack level
    func getTodayDiamondStackLevel() -> Int {
        return getDiamondStackLevelForDate(currentDate)
    }

    /// Get Hashtag Words level based on day of week
    /// Monday: L1, Tuesday: L2, Wednesday: L3, Thu-Sun: Random (1-3)
    func getHashtagWordsLevelForDate(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 2: return 1  // Monday: L1 (Easy)
        case 3: return 2  // Tuesday: L2 (Medium)
        case 4: return 3  // Wednesday: L3 (Hard)
        case 1, 5, 6, 7:  // Sun, Thu, Fri, Sat: Random 1-3
            // Use date seed for consistent random level
            let seed = getSeedForDate(date)
            return (seed % 3) + 1
        default: return 1
        }
    }

    /// Get today's Hashtag Words level
    func getTodayHashtagWordsLevel() -> Int {
        return getHashtagWordsLevelForDate(currentDate)
    }

    /// Get TraceWiz difficulty level for date (1=Easy, 2=Medium, 3=Hard)
    /// Monday: Easy, Tuesday: Medium, Wednesday: Hard, Thu-Sun: Random
    func getTraceWizLevelForDate(_ date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)

        switch weekday {
        case 2: return 1      // Monday: Easy
        case 3: return 2      // Tuesday: Medium
        case 4: return 3      // Wednesday: Hard
        case 1, 5, 6, 7:      // Sun, Thu, Fri, Sat: Random
            let seed = getSeedForDate(date)
            let randomDifficulty = seed % 3
            return randomDifficulty + 1  // Returns 1, 2, or 3
        default: return 1
        }
    }

    /// Get today's TraceWiz difficulty level
    func getTodayTraceWizLevel() -> Int {
        return getTraceWizLevelForDate(currentDate)
    }

    /// Get difficulty name for level
    func getDifficultyName(for level: Int) -> String {
        switch level {
        case 1: return "Easy"
        case 2: return "Medium"
        case 3: return "Hard"
        case 4: return "Expert"
        default: return "Easy"
        }
    }

    /// Get difficulty emoji for level
    func getDifficultyEmoji(for level: Int) -> String {
        switch level {
        case 1: return "🟢"
        case 2: return "🟡"
        case 3: return "🔴"
        case 4: return "🟣"
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

    /// Get available dates (last 30 days for archive, including today)
    func getAvailableDates(count: Int = 30) -> [Date] {
        var dates: [Date] = []
        // Start from today (i=0) to include current day in archive
        for i in 0..<count {
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
    func checkForNewDay() {
        let newDate = Date()
        let newDateString: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: newDate)
        }()
        let lastCheckString = userDefaults.string(forKey: lastCheckDateKey)

        if newDateString != lastCheckString {
            // New day! Update current date and reset completed
            self.currentDate = newDate
            completedToday.removeAll()
            saveCompletedToday()
            userDefaults.set(newDateString, forKey: lastCheckDateKey)
        }
    }
}
