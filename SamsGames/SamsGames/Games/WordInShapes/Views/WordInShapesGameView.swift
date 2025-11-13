//
//  WordInShapesGameView.swift
//  Sam's Games
//
//  Word In Shapes game integrated with daily puzzle system
//

import SwiftUI

struct WordInShapesGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GameViewModel?
    @State private var showCompletionAlert = false

    var body: some View {
        Group {
            if let viewModel = viewModel {
                GameView(viewModel: viewModel)
            } else {
                ProgressView("Loading puzzle...")
                    .font(.title2)
            }
        }
        .onAppear {
            if viewModel == nil {
                // Get today's seed for consistent daily puzzle
                let seed = dailyPuzzleManager.getSeedForToday()
                viewModel = GameViewModel(seed: seed)
                setupCompletionHandler()
                viewModel?.startNewGame()
            }
        }
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Word In Shapes puzzle in \(viewModel?.formattedTime ?? "")!")
        }
    }

    private func setupCompletionHandler() {
        viewModel?.onGameCompleted = {
            // Mark as completed in daily puzzle manager
            dailyPuzzleManager.markCompleted(.wordInShapes)

            // Record completion in statistics
            statisticsManager.recordCompletion(.wordInShapes)

            // Show completion alert
            showCompletionAlert = true
        }
    }
}
