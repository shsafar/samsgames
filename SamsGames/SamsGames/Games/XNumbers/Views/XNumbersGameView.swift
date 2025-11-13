//
//  XNumbersGameView.swift
//  Sam's Games
//
//  X-Numbers game integrated with daily puzzle system
//

import SwiftUI

struct XNumbersGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var game: XNumbersGameModel
    @State private var showCompletionAlert = false
    @State private var showInstructions = false

    init() {
        // Initialize with today's seed and level for daily puzzle
        let today = Date()
        let seed = UInt64(bitPattern: Int64(today.timeIntervalSince1970 / 86400))

        // Calculate level based on day of week
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: today)
        let level: Int
        switch weekday {
        case 1: level = 3  // Sunday: L3
        case 2: level = 1  // Monday: L1
        case 3: level = 2  // Tuesday: L2
        case 4: level = 1  // Wednesday: L1
        case 5: level = 2  // Thursday: L2
        case 6: level = 1  // Friday: L1
        case 7: level = 3  // Saturday: L3
        default: level = 1
        }

        _game = StateObject(wrappedValue: XNumbersGameModel(seed: seed, dailyPuzzleMode: true, dailyLevel: level))
    }

    var body: some View {
        NavigationView {
            FixedXNumbersGame()
                .environmentObject(game)
                .onAppear {
                    setupCompletionHandler()

                    // Generate the daily puzzle if not already started
                    if game.nodes.isEmpty {
                        game.generateNewGame()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.blue)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showInstructions = true }) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            let minutes = game.timeElapsed / 60
            let seconds = game.timeElapsed % 60
            let timeString = String(format: "%d:%02d", minutes, seconds)
            return Text("Great job! You completed today's X-Numbers puzzle in \(timeString)!")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .xNumbers)
        }
    }

    private func setupCompletionHandler() {
        game.onDailyPuzzleComplete = { [self] in
            // Mark as completed in daily puzzle manager
            dailyPuzzleManager.markCompleted(.xNumbers)

            // Record completion in statistics
            statisticsManager.recordCompletion(.xNumbers)

            // Show completion alert
            showCompletionAlert = true
        }
    }
}

#Preview {
    XNumbersGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
