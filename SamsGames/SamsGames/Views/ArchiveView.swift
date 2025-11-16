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
    @Environment(\.dismiss) var dismiss

    @State private var selectedArchiveItem: ArchiveItem?

    private let availableDates: [Date]

    // Struct to hold both date and game type together
    struct ArchiveItem: Identifiable {
        let id = UUID()
        let date: Date
        let gameType: GameType
    }

    init() {
        self.availableDates = DailyPuzzleManager().getAvailableDates(count: 30)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(availableDates, id: \.self) { date in
                    Section(header: Text(formatDate(date))) {
                        ForEach(GameType.allCases, id: \.id) { gameType in
                            ArchiveGameRow(
                                gameType: gameType,
                                date: date,
                                isCompleted: statisticsManager.isCompleted(for: gameType, on: date),
                                dailyPuzzleManager: dailyPuzzleManager
                            )
                            .onTapGesture {
                                selectedArchiveItem = ArchiveItem(date: date, gameType: gameType)
                            }
                        }
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
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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
        }
    }
}

struct ArchiveGameRow: View {
    let gameType: GameType
    let date: Date
    let isCompleted: Bool
    let dailyPuzzleManager: DailyPuzzleManager

    var body: some View {
        HStack {
            // Use custom icon if available, otherwise SF Symbol
            if let customIcon = gameType.customIcon {
                Image(customIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: gameType.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .green : .gray)
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(gameType.rawValue)
                    .foregroundColor(.primary)

                // Show difficulty for X-Numbers
                if gameType == .xNumbers {
                    let level = dailyPuzzleManager.getLevelForDate(date)
                    let emoji = dailyPuzzleManager.getDifficultyEmoji(for: level)
                    let name = dailyPuzzleManager.getDifficultyName(for: level)

                    HStack(spacing: 4) {
                        Text(emoji)
                            .font(.caption2)
                        Text("\(name) (L\(level))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Show difficulty for JushBox
                if gameType == .jushBox {
                    let level = dailyPuzzleManager.getJushBoxLevelForDate(date)
                    let emoji = dailyPuzzleManager.getDifficultyEmoji(for: level)
                    let name = dailyPuzzleManager.getDifficultyName(for: level)

                    HStack(spacing: 4) {
                        Text(emoji)
                            .font(.caption2)
                        Text("\(name) (L\(level))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}
