import SwiftUI

struct TraceWizGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var gameState: TraceWizGameState
    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var isPulsing = false
    @State private var showExitWarning = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    private let seed: Int
    private let difficulty: GameConstants.Difficulty

    init(archiveMode: Bool = false, archiveDate: Date? = nil, archiveSeed: Int? = nil) {
        self.archiveMode = archiveMode
        self.archiveDate = archiveDate
        self.archiveSeed = archiveSeed

        let manager = DailyPuzzleManager()
        let level: Int
        let seedValue: Int
        if let archiveSeed = archiveSeed, let archiveDate = archiveDate {
            seedValue = archiveSeed
            level = manager.getTraceWizLevelForDate(archiveDate)
        } else {
            seedValue = manager.getSeedForToday()
            level = manager.getTodayTraceWizLevel()
        }

        // Store seed
        self.seed = seedValue

        // Convert level to difficulty
        let difficultyValue: GameConstants.Difficulty
        switch level {
        case 1: difficultyValue = .easy
        case 2: difficultyValue = .medium
        case 3: difficultyValue = .hard
        default: difficultyValue = .easy
        }
        self.difficulty = difficultyValue

        // Initialize game state with the seed value
        _gameState = StateObject(wrappedValue: TraceWizGameState(seed: seedValue))
    }

    var body: some View {
        Group {
            if showSplash {
                splashScreen
            } else {
                gameContent
            }
        }
        .onAppear {
            startSplashTimer()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .traceWiz)
        }
        .alert("Puzzle Complete!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            if gameState.gameWon {
                Text("Congratulations! You completed today's TraceWiz puzzle!")
            } else {
                Text("Game Over! Try again tomorrow for a new puzzle.")
            }
        }
        .alert("Exit Game?", isPresented: $showExitWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure? You may lose your progress if you exit.")
        }
    }

    // MARK: - Splash Screen

    private var splashScreen: some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Try to load the custom icon
                if let customIcon = GameType.traceWiz.customIcon,
                   let uiImage = UIImage(named: customIcon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280, maxHeight: 280)
                        .padding(.horizontal, 20)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                } else {
                    // Fallback to SF Symbol
                    Image(systemName: "scribble.variable")
                        .font(.system(size: 120))
                        .foregroundColor(.blue)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Text("TraceWiz")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            isPulsing = true
        }
    }

    // MARK: - Game Content

    private var gameContent: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                    .gesture(DragGesture()) // Block sheet dismiss gesture

                VStack(spacing: 8) {
                    // Game Canvas - Takes most of the space
                    ZStack {
                        GameCanvasView(
                            gameState: gameState,
                            canvasSize: CGSize(
                                width: geometry.size.width - 16,
                                height: geometry.size.height - 200
                            )
                        )
                        .frame(
                            width: geometry.size.width - 16,
                            height: geometry.size.height - 200
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onAppear {
                            gameState.canvasSize = CGSize(
                                width: geometry.size.width - 16,
                                height: geometry.size.height - 200
                            )
                            gameState.difficulty = difficulty
                            gameState.generateNewPath()
                        }
                        .onChange(of: geometry.size) { oldValue, newValue in
                            gameState.canvasSize = CGSize(
                                width: newValue.width - 16,
                                height: geometry.size.height - 200
                            )
                            gameState.generateNewPath()
                        }
                        .onChange(of: gameState.gameCompleted) { oldValue, completed in
                            if completed && gameState.gameWon {
                                // Mark as completed in daily puzzle manager (only for today's puzzle)
                                if !archiveMode {
                                    dailyPuzzleManager.markCompleted(.traceWiz)
                                }

                                // Record completion in statistics (for both today and archive)
                                if let archiveDate = archiveDate {
                                    statisticsManager.recordCompletion(.traceWiz, date: archiveDate)
                                } else {
                                    statisticsManager.recordCompletion(.traceWiz)
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    showCompletionAlert = true
                                }
                            }
                        }

                        // HUD Overlay
                        VStack {
                            HStack {
                                Text(gameState.phase.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(phaseColor(gameState.phase).opacity(0.9))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)

                                if gameState.phase == .running {
                                    Text(String(format: "%.1fs", gameState.roundTime))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.9))
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }

                                Spacer()

                                Button(action: { showInstructions = true }) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(8)

                            Spacer()
                        }

                        // Countdown Overlay
                        if gameState.phase == .countdown {
                            VStack {
                                if gameState.countdownTime > 0 {
                                    Text("\(Int(ceil(gameState.countdownTime)))")
                                        .font(.system(size: 100, weight: .bold))
                                        .foregroundColor(.orange)
                                        .shadow(radius: 10)
                                } else {
                                    Text("GO!")
                                        .font(.system(size: 100, weight: .bold))
                                        .foregroundColor(.green)
                                        .shadow(radius: 10)
                                }
                            }
                        }

                        // Game Over Overlay
                        if gameState.phase == .ended {
                            VStack(spacing: 15) {
                                Text(gameState.player.isEliminated ? "💥 Game Over" : "🎉 You Won!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(gameState.player.isEliminated ? .red : .green)

                                if let reason = gameState.player.eliminationReason {
                                    Text(reason)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(30)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(15)
                            .shadow(radius: 15)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    // Bottom Control Panel
                    VStack(spacing: 8) {
                        // Title and Difficulty Row
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("TraceWiz")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                if archiveMode, let date = archiveDate {
                                    Text(formatArchiveDate(date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Daily Puzzle")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Difficulty Display
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(difficultyEmoji(for: difficulty))
                                        .font(.caption)
                                    Text(difficulty.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(6)

                                Text(difficultyDescription(for: difficulty))
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(2)
                                    .frame(maxWidth: 140)
                            }
                        }

                        // Control Buttons Row
                        HStack(spacing: 12) {
                            Button(action: { gameState.startGame() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.fill")
                                        .font(.caption)
                                    Text("Start")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(gameState.phase != .idle)

                            Button(action: { gameState.resetGame() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.caption)
                                    Text("Reset")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }

                            Button(action: { showExitWarning = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                    Text("Exit")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }

                        // Quick Instructions
                        Text("Draw with your finger • Follow the black line • Don't cross it!")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func startSplashTimer() {
        // Show splash for 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showSplash = false
            }
        }
    }

    private func phaseColor(_ phase: GamePhase) -> Color {
        switch phase {
        case .idle: return .gray
        case .countdown: return .orange
        case .running: return .green
        case .paused: return .yellow
        case .ended: return .red
        }
    }

    private func difficultyEmoji(for difficulty: GameConstants.Difficulty) -> String {
        switch difficulty.name {
        case "Easy": return "🟢"
        case "Medium": return "🟡"
        case "Hard": return "🔴"
        default: return "⚪"
        }
    }

    private func difficultyDescription(for difficulty: GameConstants.Difficulty) -> String {
        switch difficulty.name {
        case "Easy":
            return "Slower reveal, generous tolerance"
        case "Medium":
            return "Moderate speed, balanced tolerance"
        case "Hard":
            return "Fast reveal, tight tolerance"
        default:
            return ""
        }
    }

    private func formatArchiveDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
