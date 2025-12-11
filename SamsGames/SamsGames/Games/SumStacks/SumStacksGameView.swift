//
//  SumStacksGameView.swift
//  Sam's Games
//
//  SumStacks game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct SumStacksGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var showExitWarning = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Check if already completed (for both regular and archive mode)
    private var isAlreadyCompleted: Bool {
        if archiveMode {
            // In archive mode, NEVER show completed screen - always allow replay
            return false
        }
        // Regular mode - check if today is completed
        return dailyPuzzleManager.isCompletedToday(.sumStacks)
    }

    @State private var showIconAnimation = true
    @State private var iconScale: CGFloat = 1.0

    var body: some View {
        Group {
            if isAlreadyCompleted {
                // Show completion screen if already completed today
                SumStacksCompletedView()
            } else {
                ZStack {
                NavigationView {
                    SumStacksWebView(
                        archiveMode: archiveMode,
                        archiveDate: archiveDate,
                        archiveSeed: archiveSeed,
                        onComplete: {
                            handleCompletion()
                        }
                    )
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

                // Animated icon overlay with pulsing effect
                if showIconAnimation {
                    ZStack {
                        Color.white
                            .ignoresSafeArea()

                        Image("sumstackicon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .scaleEffect(iconScale)
                    }
                    .transition(.opacity)
                }
            }
            }
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()

            if !isAlreadyCompleted {
                // Animate icon flashing 3 times over 3 seconds
                withAnimation(.easeInOut(duration: 0.5).repeatCount(6, autoreverses: true)) {
                    iconScale = 1.3
                }

                // Hide icon after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showIconAnimation = false
                    }
                }
            } else {
                showIconAnimation = false
            }
        }
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's SumStacks puzzle!")
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
            GameInstructionsView(gameType: .sumStacks)
        }
    }

    private func handleCompletion() {
        if archiveMode {
            // Archive mode - record completion for the specific archive date
            if let date = archiveDate {
                statisticsManager.recordCompletion(.sumStacks, date: date)
            }
        } else {
            // Regular mode - mark today as completed
            dailyPuzzleManager.markCompleted(.sumStacks)
            statisticsManager.recordCompletion(.sumStacks)
        }

        // Show completion alert
        showCompletionAlert = true
    }
}

// MARK: - WebView Wrapper

struct SumStacksWebView: View {
    let archiveMode: Bool
    let archiveDate: Date?
    let archiveSeed: Int?
    let onComplete: () -> Void

    @State private var soundEnabled = true
    @State private var webView: WKWebView?
    @State private var showQuickTips = false
    @State private var gameTime: String = "0:00"
    @State private var scoreCount: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Standardized button bar
            StandardGameButtonBar(
                onReset: {
                    resetGame()
                },
                onRevealHint: {
                    revealSolution()
                },
                soundEnabled: $soundEnabled,
                resetLabel: "START/RESET",
                showReveal: true  // Enable reveal button
            )

            // Game title with special instructions icon
            HStack(spacing: 8) {
                Text("SumStacks")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                // Special instructions (i) icon - gray for SumStacks (no special tips)
                Button(action: {
                    // No special tips for SumStacks, so this does nothing
                    // showQuickTips = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)  // Gray = no special instructions
                }
                .disabled(true)  // Disabled since no special tips
            }
            .padding(.vertical, 12)

            // Standardized game info bar
            StandardGameInfoBar(
                time: gameTime,
                score: (scoreCount, "Score"),  // Active: Time and Score
                moves: nil,     // Inactive (gray)
                streak: nil,    // Inactive (gray)
                hints: nil,     // Inactive (gray)
                penalty: nil    // Inactive (gray)
            )

            // WebView game
            SumStacksWebViewRepresentable(
                archiveMode: archiveMode,
                archiveDate: archiveDate,
                archiveSeed: archiveSeed,
                onComplete: onComplete,
                webView: $webView,
                gameTime: $gameTime,
                scoreCount: $scoreCount
            )
        }
        .onChange(of: soundEnabled) { _, newValue in
            webView?.evaluateJavaScript("setSoundEnabled(\(newValue));")
        }
    }

    private func resetGame() {
        webView?.evaluateJavaScript("resetGame();") { _, error in
            if let error = error {
                print("❌ Reset error: \(error)")
            }
        }
    }

    private func revealSolution() {
        webView?.evaluateJavaScript("revealSolution();") { _, error in
            if let error = error {
                print("❌ Reveal error: \(error)")
            }
        }
    }
}

// MARK: - WebView UIViewRepresentable

struct SumStacksWebViewRepresentable: UIViewRepresentable {
    let archiveMode: Bool
    let archiveDate: Date?
    let archiveSeed: Int?
    let onComplete: () -> Void
    @Binding var webView: WKWebView?
    @Binding var gameTime: String
    @Binding var scoreCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onComplete: onComplete,
            webViewBinding: $webView,
            gameTime: $gameTime,
            scoreCount: $scoreCount
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true

        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "gameCompleted")
        contentController.add(context.coordinator, name: "gameStats")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = .white

        // Store webView reference via coordinator
        context.coordinator.webViewBinding.wrappedValue = webView

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load once - prevent reload loop
        if context.coordinator.hasLoaded {
            return
        }
        context.coordinator.hasLoaded = true

        guard let htmlPath = Bundle.main.path(forResource: "sumstacks", ofType: "html") else {
            print("❌ Could not find sumstacks.html")
            return
        }

        let htmlURL = URL(fileURLWithPath: htmlPath)
        let request = URLRequest(url: htmlURL)
        webView.load(request)

        // Set up daily puzzle mode after page loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Use provided archive seed, or calculate from date
            let seed: Int64
            if let archiveSeed = archiveSeed {
                seed = Int64(archiveSeed)
            } else {
                let date = archiveDate ?? Date()
                seed = Int64(date.timeIntervalSince1970 / 86400)
            }

            // Check if functions exist and call them in sequence
            webView.evaluateJavaScript("typeof setSeed !== 'undefined' && typeof startGame !== 'undefined'") { result, error in
                if let ready = result as? Bool, ready {
                    // Set seed first
                    webView.evaluateJavaScript("setSeed(\(seed));") { _, _ in
                        // Then start game
                        webView.evaluateJavaScript("startGame();") { _, error in
                            if let error = error {
                                print("❌ Error starting game: \(error)")
                            }
                        }
                    }
                } else {
                    print("❌ JavaScript functions not ready")
                }
            }
        }
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        let onComplete: () -> Void
        let webViewBinding: Binding<WKWebView?>
        let gameTime: Binding<String>
        let scoreCount: Binding<Int>
        var hasLoaded: Bool = false

        init(onComplete: @escaping () -> Void,
             webViewBinding: Binding<WKWebView?>,
             gameTime: Binding<String>,
             scoreCount: Binding<Int>) {
            self.onComplete = onComplete
            self.webViewBinding = webViewBinding
            self.gameTime = gameTime
            self.scoreCount = scoreCount
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted" {
                DispatchQueue.main.async {
                    self.onComplete()
                }
            } else if message.name == "gameStats" {
                if let stats = message.body as? [String: Any] {
                    DispatchQueue.main.async {
                        if let time = stats["time"] as? String {
                            self.gameTime.wrappedValue = time
                        }
                        if let solved = stats["solved"] as? Int {
                            self.scoreCount.wrappedValue = solved
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Already Completed View

struct SumStacksCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timeUntilNext = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Orange gradient background (for number/math theme)
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.6),
                    Color.orange.opacity(0.8)
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

                        Text("Great job! You've finished today's SumStacks puzzle.")
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
    SumStacksGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
