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
    @State private var showExitWarning = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil

    // Check if already completed today (only for non-archive mode)
    private var isAlreadyCompleted: Bool {
        if archiveMode {
            return false // Archive mode always allows play
        }
        return dailyPuzzleManager.isCompletedToday(.xNumbers)
    }

    init(archiveMode: Bool = false, archiveDate: Date? = nil) {
        self.archiveMode = archiveMode
        self.archiveDate = archiveDate

        // Use archiveDate or today
        let date = archiveDate ?? Date()
        let seed = UInt64(bitPattern: Int64(date.timeIntervalSince1970 / 86400))

        // Calculate level based on day of week
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
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
        Group {
            if isAlreadyCompleted {
                // Show completion screen if already completed today
                XNumbersCompletedView()
            } else {
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
                                Button(action: { showExitWarning = true }) {
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
            }
        }
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
        .alert("Exit Game?", isPresented: $showExitWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure? You may lose your progress if you exit.")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .xNumbers)
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()
        }
    }

    private func setupCompletionHandler() {
        game.onDailyPuzzleComplete = { [self] in
            // Only mark as completed if not in archive mode
            if !archiveMode {
                // Mark as completed in daily puzzle manager
                dailyPuzzleManager.markCompleted(.xNumbers)

                // Record completion in statistics
                statisticsManager.recordCompletion(.xNumbers)
            }

            // Show completion alert
            showCompletionAlert = true
        }
    }
}

// MARK: - Already Completed View

struct XNumbersCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timeUntilNext = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Purple gradient background
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.6),
                    Color.purple.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                Spacer()

                VStack(spacing: 30) {
                    // Completion message
                    VStack(spacing: 12) {
                        Text("Puzzle Completed!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Great job! You've finished today's X-Numbers puzzle.")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    // Countdown
                    VStack(spacing: 8) {
                        Text("Next puzzle in:")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))

                        Text(timeUntilNext)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                    )

                    Text("Try past puzzles in the Archive!")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
            }
        }
        .onReceive(timer) { _ in
            updateCountdown()
        }
        .onAppear {
            updateCountdown()
        }
    }

    private func updateCountdown() {
        let now = Date()
        let calendar = Calendar.current

        // Get start of tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let startOfTomorrow = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            timeUntilNext = "Soon!"
            return
        }

        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: startOfTomorrow)

        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        timeUntilNext = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    XNumbersGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
