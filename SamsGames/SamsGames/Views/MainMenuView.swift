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
                VStack(spacing: 20) {
                    // Header
                    headerView

                    // Today's Date
                    todayDateView

                    // Game Cards
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
                        .onTapGesture {
                            if gameType == .jushBox {
                                showJushBox = true
                            } else {
                                selectedGame = gameType
                            }
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
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(item: $selectedGame) { gameType in
                if gameType != .jushBox {
                    if isIPad {
                        // iPad: Full screen cover-like presentation
                        gameView(for: gameType)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                            .interactiveDismissDisabled(false)
                    } else {
                        // iPhone: Standard sheet
                        gameView(for: gameType)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                    }
                }
            }
            .fullScreenCover(isPresented: $showJushBox) {
                WebJushBoxGameView()
                    .environmentObject(dailyPuzzleManager)
                    .environmentObject(statisticsManager)
            }
            .sheet(isPresented: $showArchive) {
                ArchiveView()
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsMenuView()
            }
            .sheet(item: $showInstructions) { gameType in
                GameInstructionsView(gameType: gameType)
            }
        }
        .navigationViewStyle(.stack) // Force single column on iPad
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Sam's Games")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)

            Text("Daily Puzzles")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var todayDateView: some View {
        Text(dailyPuzzleManager.getTodayString())
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.bottom, 10)
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

    var body: some View {
        HStack(spacing: 15) {
            // Game Icon
            ZStack {
                if let customIcon = gameType.customIcon {
                    // Use custom asset image
                    Image(customIcon)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    // Fallback to SF Symbol
                    Image(systemName: gameType.icon)
                        .font(.system(size: 40))
                        .foregroundColor(isCompleted ? .green : .blue)
                }
            }
            .frame(width: 60, height: 60)
            .background(isCompleted ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
            .cornerRadius(12)

            // Game Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(gameType.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Button(action: onInfoTapped) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Text(gameType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Show difficulty for X-Numbers
                if gameType == .xNumbers {
                    let level = dailyPuzzleManager.getTodayLevel()
                    let emoji = dailyPuzzleManager.getDifficultyEmoji(for: level)
                    let name = dailyPuzzleManager.getDifficultyName(for: level)

                    HStack(spacing: 4) {
                        Text(emoji)
                            .font(.caption)
                        Text("\(name) (Level \(level))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Show difficulty for JushBox
                if gameType == .jushBox {
                    let level = dailyPuzzleManager.getTodayJushBoxLevel()
                    let emoji = dailyPuzzleManager.getDifficultyEmoji(for: level)
                    let name = dailyPuzzleManager.getDifficultyName(for: level)

                    HStack(spacing: 4) {
                        Text(emoji)
                            .font(.caption)
                        Text("\(name) (Level \(level))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(currentStreak) day streak")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // Completion Status
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
