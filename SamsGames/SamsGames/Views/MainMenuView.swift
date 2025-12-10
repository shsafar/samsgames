//
//  MainMenuView.swift
//  Sam's Games
//
//  Main menu showing all available games (NYT Games style)
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @State private var selectedGame: GameType?
    @State private var showJushBox = false
    @State private var showArchive = false
    @State private var showStatistics = false
    @State private var showSettings = false
    @State private var showInstructions: GameType?

    // Detect if running on iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerView

                    // Game Cards (removed separate date view, now on each card)
                    ForEach(GameType.allCases, id: \.id) { gameType in
                        GameCard(
                            gameType: gameType,
                            isCompleted: dailyPuzzleManager.isCompletedToday(gameType),
                            currentStreak: statisticsManager.getCurrentStreak(for: gameType),
                            onInfoTapped: {
                                showInstructions = gameType
                            },
                            dailyPuzzleManager: dailyPuzzleManager
                        )
                        .environmentObject(statisticsManager)
                        .onTapGesture {
                            if gameType == .jushBox {
                                showJushBox = true
                            } else {
                                selectedGame = gameType
                            }
                        }

                        // Show scroll indicator after Double Bubble
                        if gameType == .doubleBubble {
                            VStack(spacing: 6) {
                                Image(systemName: "chevron.compact.down")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("Scroll for more")
                                    .font(.caption2)
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    Spacer(minLength: 50)
                }
                .padding()
                .frame(maxWidth: 600) // Limit width on iPad
                .frame(maxWidth: .infinity) // Center it
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title3)
                        }
                        Button(action: { showStatistics = true }) {
                            Image(systemName: "chart.bar.fill")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showArchive = true }) {
                        Text("Archive")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
            }
            // Show games in fullscreen on iPad, sheet on iPhone
            .fullScreenCover(item: isIPad ? $selectedGame : .constant(nil)) { gameType in
                if gameType != .jushBox {
                    gameView(for: gameType)
                }
            }
            .sheet(item: !isIPad ? $selectedGame : .constant(nil)) { gameType in
                if gameType != .jushBox {
                    gameView(for: gameType)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.hidden)
                        .interactiveDismissDisabled(gameType == .traceWiz)
                }
            }
            .fullScreenCover(isPresented: $showJushBox) {
                WebJushBoxGameView()
                    .environmentObject(dailyPuzzleManager)
                    .environmentObject(statisticsManager)
            }
            // Archive - fullscreen on iPad, sheet on iPhone
            .fullScreenCover(isPresented: isIPad ? $showArchive : .constant(false)) {
                ArchiveView()
            }
            .sheet(isPresented: !isIPad ? $showArchive : .constant(false)) {
                ArchiveView()
            }
            // Statistics - fullscreen on iPad, sheet on iPhone
            .fullScreenCover(isPresented: isIPad ? $showStatistics : .constant(false)) {
                StatisticsView()
            }
            .sheet(isPresented: !isIPad ? $showStatistics : .constant(false)) {
                StatisticsView()
            }
            // Settings - fullscreen on iPad, sheet on iPhone
            .fullScreenCover(isPresented: isIPad ? $showSettings : .constant(false)) {
                SettingsMenuView()
            }
            .sheet(isPresented: !isIPad ? $showSettings : .constant(false)) {
                SettingsMenuView()
            }
            // Instructions - fullscreen on iPad, sheet on iPhone
            .fullScreenCover(item: isIPad ? $showInstructions : .constant(nil)) { gameType in
                GameInstructionsView(gameType: gameType)
            }
            .sheet(item: !isIPad ? $showInstructions : .constant(nil)) { gameType in
                GameInstructionsView(gameType: gameType)
            }
        }
        .navigationViewStyle(.stack) // Force single column on iPad
        .onAppear {
            // Check if new day when main menu appears
            dailyPuzzleManager.checkForNewDay()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("Sam's Games")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)

            Text("Daily Puzzles")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var todayDateView: some View {
        Text(dailyPuzzleManager.getTodayString())
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func gameView(for gameType: GameType) -> some View {
        switch gameType {
        case .xNumbers:
            XNumbersGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .wordInShapes:
            WebWordInShapesGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .jushBox:
            // JushBox uses fullScreenCover instead, not this sheet
            EmptyView()
        case .doubleBubble:
            WebDoubleBubbleGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .diamondStack:
            WebDiamondStackGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .hashtagWords:
            WebHashtagWordsGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .traceWiz:
            TraceWizGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .arrowRace:
            WebArrowRaceGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .diskBreak:
            WebDiskBreakGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .waterTable:
            WebWaterTableGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .atomicNails:
            WebAtomicNailsGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .wordStacks:
            WebWordStacksGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .sumStacks:
            SumStacksGameView()
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        }
    }
}

// MARK: - Game Card Component

struct GameCard: View {
    let gameType: GameType
    let isCompleted: Bool
    let currentStreak: Int
    let onInfoTapped: () -> Void
    let dailyPuzzleManager: DailyPuzzleManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var statisticsManager: StatisticsManager
    @State private var showArchive = false

    // NYT-style branded colors for each game
    private var brandColor: Color {
        switch gameType {
        case .sumStacks:
            return Color.orange
        case .wordStacks:
            return Color.orange.opacity(0.8)
        case .xNumbers:
            return Color.blue
        case .wordInShapes:
            return Color.purple
        case .jushBox:
            return Color.green
        case .doubleBubble:
            return Color.pink
        case .diamondStack:
            return Color.indigo
        case .hashtagWords:
            return Color.teal
        case .traceWiz:
            return Color.cyan
        case .arrowRace:
            return Color.red
        case .diskBreak:
            return Color.yellow
        case .waterTable:
            return Color.blue.opacity(0.7)
        case .atomicNails:
            return Color.gray
        }
    }

    var body: some View {
        Group {
            if gameType == .sumStacks {
                // SumStacks with horizontal scroll for week view
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Main card content
                        HStack(alignment: .top, spacing: 12) {
                            // Left side - Game info
                            VStack(alignment: .leading, spacing: 6) {
                                // Game title
                                Text(gameType.rawValue)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                // Attribution text
                                Text("By Sam H S")
                                    .font(.system(size: 11))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))

                                // Description
                                Text(gameType.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                                    .lineLimit(2)

                                // Date display (NYT style)
                                Text(dailyPuzzleManager.getTodayString())
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black)
                                    .padding(.top, 2)

                                // Difficulty level
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 10, height: 10)
                                    Text("Easy (L1)")
                                        .font(.system(size: 12))
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                                }
                            }

                            Spacer()

                            // Right side - Game icon
                            ZStack {
                                if let customIcon = gameType.customIcon {
                                    Image(customIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                } else {
                                    Image(systemName: gameType.icon)
                                        .font(.system(size: 45))
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                            .frame(width: 70, height: 70)

                            // Completion indicator if completed
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                    .offset(x: -8, y: -8)
                            }
                        }
                        .padding(16)
                        .frame(width: 360)
                        .background(brandColor.opacity(colorScheme == .dark ? 0.3 : 0.15))
                        .cornerRadius(16)

                        // Week scroll view
                        WeekScrollView(
                            gameType: gameType,
                            dailyPuzzleManager: dailyPuzzleManager,
                            statisticsManager: statisticsManager,
                            brandColor: brandColor,
                            showArchive: $showArchive
                        )
                    }
                }
                .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            } else {
                // Other games - standard card
                HStack(alignment: .top, spacing: 12) {
                    // Left side - Game info
                    VStack(alignment: .leading, spacing: 6) {
                        // Game title
                        Text(gameType.rawValue)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)

                        // Description
                        Text(gameType.description)
                            .font(.system(size: 14))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                            .lineLimit(2)

                        // Date display (NYT style)
                        Text(dailyPuzzleManager.getTodayString())
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black)
                            .padding(.top, 2)

                        // Difficulty info
                        if gameType == .xNumbers {
                            let level = dailyPuzzleManager.getTodayLevel()
                            let name = dailyPuzzleManager.getDifficultyName(for: level)
                            Text(name)
                                .font(.system(size: 12))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                        } else if gameType == .jushBox {
                            let level = dailyPuzzleManager.getTodayJushBoxLevel()
                            let name = dailyPuzzleManager.getDifficultyName(for: level)
                            Text(name)
                                .font(.system(size: 12))
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                        }
                    }

                    Spacer()

                    // Right side - Game icon
                    ZStack {
                        if let customIcon = gameType.customIcon {
                            Image(customIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        } else {
                            Image(systemName: gameType.icon)
                                .font(.system(size: 45))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .frame(width: 70, height: 70)

                    // Completion indicator if completed
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.green)
                            .clipShape(Circle())
                            .offset(x: -8, y: -8)
                    }
                }
                .padding(16)
                .background(brandColor.opacity(colorScheme == .dark ? 0.3 : 0.15))
                .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
        }
        .sheet(isPresented: $showArchive) {
            ArchiveView(filterGameType: .sumStacks)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        }
    }
}

// MARK: - Week Scroll View Component
struct WeekScrollView: View {
    let gameType: GameType
    let dailyPuzzleManager: DailyPuzzleManager
    let statisticsManager: StatisticsManager
    let brandColor: Color
    @Binding var showArchive: Bool
    @Environment(\.colorScheme) var colorScheme

    private var last7Days: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }.reversed()
    }

    var body: some View {
        HStack(spacing: 16) {
            // Show last 7 days
            ForEach(last7Days, id: \.self) { date in
                WeekDayCard(
                    date: date,
                    gameType: gameType,
                    isCompleted: statisticsManager.isCompleted(for: gameType, on: date),
                    brandColor: brandColor
                )
            }

            // "Go to Archive" button as rounded square
            Button(action: {
                showArchive = true
            }) {
                VStack(spacing: 4) {
                    Text("Go to")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Archive")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 70)
                .background(Color(red: 0.3, green: 0.2, blue: 0.5))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.trailing, 8)
        .background(brandColor.opacity(colorScheme == .dark ? 0.3 : 0.15))
        .cornerRadius(16)
    }
}

// MARK: - Week Day Card Component
struct WeekDayCard: View {
    let date: Date
    let gameType: GameType
    let isCompleted: Bool
    let brandColor: Color
    @Environment(\.colorScheme) var colorScheme

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Day name on top
            Text(dayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black.opacity(0.6))

            // Icon or checkmark in center - SQUARE shape with brand color background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(brandColor.opacity(0.15))
                    .frame(width: 70, height: 70)

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                } else {
                    if let customIcon = gameType.customIcon {
                        Image(customIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                    } else {
                        Image(systemName: gameType.icon)
                            .font(.system(size: 36))
                            .foregroundColor(brandColor)
                    }
                }
            }

            // Day number on bottom
            Text(dayNumber)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black.opacity(0.6))
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
            .environmentObject(DailyPuzzleManager())
            .environmentObject(StatisticsManager())
    }
}
