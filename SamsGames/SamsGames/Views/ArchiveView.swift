//
//  ArchiveView.swift
//  Sam's Games
//
//  View to browse and play previous days' puzzles
//

import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss

    @State private var selectedArchiveItem: ArchiveItem?
    @State private var showPaywall = false

    private let availableDates: [Date]
    var filterGameType: GameType? = nil  // Optional filter for specific game

    // Struct to hold both date and game type together
    struct ArchiveItem: Identifiable {
        let id = UUID()
        let date: Date
        let gameType: GameType
    }

    init(filterGameType: GameType? = nil) {
        self.filterGameType = filterGameType
        self.availableDates = DailyPuzzleManager().getAvailableDates(count: 30)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if subscriptionManager.isSubscribedOrTestMode {
                    // Premium or Test Mode: Show archive (NYT-style cards)
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(availableDates, id: \.self) { date in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Date header
                                    Text(formatDate(date))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                        .padding(.top, 8)

                                    // Game cards for this date - filtered if needed
                                    ForEach(filteredGameTypes(), id: \.id) { gameType in
                                        ArchiveGameCard(
                                            gameType: gameType,
                                            date: date,
                                            isCompleted: statisticsManager.isCompleted(for: gameType, on: date),
                                            dailyPuzzleManager: dailyPuzzleManager
                                        )
                                        .onTapGesture {
                                            selectedArchiveItem = ArchiveItem(date: date, gameType: gameType)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                } else {
                    // Free: Show locked archive with upgrade prompt
                    VStack(spacing: 30) {
                        Spacer()

                        Image(systemName: "key.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.purple.opacity(0.6))

                        VStack(spacing: 12) {
                            Text("Archive Locked")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Upgrade to Premium to access past puzzles")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button(action: {
                            showPaywall = true
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Upgrade to Premium")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 280)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedArchiveItem) { item in
                archiveGameView(for: item.gameType, date: item.date)
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(item.gameType == .traceWiz)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func filteredGameTypes() -> [GameType] {
        if let filterGameType = filterGameType {
            return [filterGameType]
        }
        return GameType.allCases
    }

    @ViewBuilder
    private func archiveGameView(for gameType: GameType, date: Date) -> some View {
        let seed = dailyPuzzleManager.getSeedForDate(date)

        switch gameType {
        case .xNumbers:
            XNumbersGameView(archiveMode: true, archiveDate: date)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .wordInShapes:
            WebWordInShapesGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .jushBox:
            WebJushBoxGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .doubleBubble:
            WebDoubleBubbleGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .diamondStack:
            WebDiamondStackGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .hashtagWords:
            WebHashtagWordsGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .traceWiz:
            TraceWizGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .arrowRace:
            WebArrowRaceGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .diskBreak:
            WebDiskBreakGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .waterTable:
            WebWaterTableGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .atomicNails:
            WebAtomicNailsGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .wordStacks:
            WebWordStacksGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        case .sumStacks:
            SumStacksGameView(archiveMode: true, archiveDate: date, archiveSeed: seed)
                .environmentObject(dailyPuzzleManager)
                .environmentObject(statisticsManager)
        }
    }
}

struct ArchiveGameCard: View {
    let gameType: GameType
    let date: Date
    let isCompleted: Bool
    let dailyPuzzleManager: DailyPuzzleManager
    @Environment(\.colorScheme) var colorScheme

    // Helper function to get difficulty color
    private func difficultyColor(for level: Int) -> Color {
        switch level {
        case 1:
            return Color.green
        case 2:
            return Color.yellow
        case 3:
            return Color.red
        default:
            return Color.gray
        }
    }

    // NYT-style branded colors (same as main menu)
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
        HStack(alignment: .center, spacing: 16) {
            // Left side - Game icon (larger)
            ZStack {
                if let customIcon = gameType.customIcon {
                    Image(customIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                } else {
                    Image(systemName: gameType.icon)
                        .font(.system(size: 40))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .frame(width: 60, height: 60)

            // Middle - Game info
            VStack(alignment: .leading, spacing: 4) {
                Text(gameType.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text(gameType.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                // Difficulty info with colored circle
                if gameType == .xNumbers || gameType == .jushBox {
                    let seed = dailyPuzzleManager.getSeedForDate(date)
                    let calendar = Calendar.current
                    let daysSinceEpoch = calendar.dateComponents([.day], from: Date(timeIntervalSince1970: 0), to: date).day ?? 0
                    let level = (daysSinceEpoch % 3) + 1
                    let name = dailyPuzzleManager.getDifficultyName(for: level)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(difficultyColor(for: level))
                            .frame(width: 8, height: 8)
                        Text(name)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else if gameType == .sumStacks {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Easy (L1)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }

            Spacer()

            // Right side - Completion status
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(brandColor.opacity(colorScheme == .dark ? 0.2 : 0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(brandColor.opacity(0.3), lineWidth: 1)
        )
    }
}
