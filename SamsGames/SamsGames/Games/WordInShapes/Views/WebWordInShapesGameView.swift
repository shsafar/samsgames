//
//  WebWordInShapesGameView.swift
//  Sam's Games
//
//  HTML-based Word In Shapes integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebWordInShapesGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showCompletionAlert = false
    @State private var gameTime: String = "0:00"
    @State private var gameScore: Int = 0
    @State private var gameStreak: Int = 0
    @State private var gamePenalty: Int = 0
    @State private var hintsUsed: Int = 0
    @State private var showInstructions = false
    @State private var showExitWarning = false
    @State private var soundEnabled = true  // For standardized UI
    @State private var showInfoPopup = false  // For info button
    @State private var webView: WKWebView?  // Reference to call JavaScript

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Computed seed - properly initialized BEFORE WebView creation
    private var seed: Int {
        if let archiveSeed = archiveSeed {
            return archiveSeed
        }
        return dailyPuzzleManager.getSeedForToday()
    }

    // Check if already completed today (only for non-archive mode)
    private var isAlreadyCompleted: Bool {
        if archiveMode {
            return false // Archive mode always allows play
        }
        return dailyPuzzleManager.isCompletedToday(.wordInShapes)
    }

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()

            // Show either completed screen or game
            if isAlreadyCompleted {
                WordInShapesCompletedView()
            } else {
                VStack(spacing: 0) {
                    // TOP BAR - Back and ? buttons (above standardized menu)
                    HStack {
                        Button(action: { showExitWarning = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                Text("Back")
                                    .font(.body)
                            }
                            .foregroundColor(.purple)
                        }

                        Spacer()

                        Button(action: { showInstructions = true }) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color(UIColor.systemBackground))

                    // STANDARDIZED UI - Button Bar
                    StandardGameButtonBar(
                        onReset: {
                            // Call newGame() in HTML game
                            print("🔵 START/RESET button pressed")
                            guard let webView = webView else {
                                print("❌ webView is nil!")
                                return
                            }
                            print("✅ webView exists")
                            let script = """
                            if (typeof window.newGame === 'function') {
                                console.log('✅ Calling window.newGame()');
                                window.newGame();
                            } else {
                                console.log('❌ window.newGame is not defined');
                            }
                            """
                            webView.evaluateJavaScript(script) { result, error in
                                if let error = error {
                                    print("❌ Error calling newGame(): \(error)")
                                } else {
                                    print("✅ Called newGame() - result: \(String(describing: result))")
                                }
                            }
                        },
                        onRevealHint: {
                            // Click the HTML hint button
                            print("🔵 REVEAL/HINT button pressed")
                            guard let webView = webView else {
                                print("❌ webView is nil!")
                                return
                            }
                            print("✅ webView exists")
                            let script = """
                            var btn = document.getElementById('hintBtn');
                            if (btn) {
                                console.log('✅ Found hintBtn, clicking it');
                                btn.click();
                            } else {
                                console.log('❌ hintBtn not found');
                            }
                            """
                            webView.evaluateJavaScript(script) { result, error in
                                if let error = error {
                                    print("❌ Error clicking hint button: \(error)")
                                } else {
                                    print("✅ Clicked hint button - result: \(String(describing: result))")
                                }
                            }
                        },
                        soundEnabled: $soundEnabled,
                        resetLabel: "START/RESET",
                        revealLabel: "REVEAL/HINT"
                    )

                    // STANDARDIZED UI - Game Title
                    HStack {
                        Spacer()
                        Text("Words In Shapes")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Button(action: {
                            showInfoPopup = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color(UIColor.systemBackground))

                    // STANDARDIZED UI - Info Bar
                    StandardGameInfoBar(
                        time: gameTime,
                        score: (gameScore, "Score"),
                        moves: nil,
                        streak: gameStreak,
                        hints: hintsUsed,
                        penalty: (gamePenalty, "Hint Penalty")
                    )

                    // WebView for the game
                    WebGameViewRepresentable(
                        seed: seed,
                        onGameCompleted: archiveMode ? { _, _ in } : handleGameCompletion,
                        onWebViewCreated: { createdWebView in
                            DispatchQueue.main.async {
                                print("✅ WebView created and reference stored")
                                webView = createdWebView
                            }
                        },
                        onTimeUpdate: { time in
                            gameTime = time
                        },
                        onScoreUpdate: { score in
                            gameScore = score
                        },
                        onStreakUpdate: { streak in
                            gameStreak = streak
                        },
                        onPenaltyUpdate: { penalty in
                            gamePenalty = penalty
                        },
                        onHintsUpdate: { hints in
                            hintsUsed = hints
                        }
                    )
                    .id(seed) // Force recreation when seed changes (new day)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Word In Shapes puzzle!\n\nScore: \(gameScore)\nTime: \(gameTime)")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .wordInShapes)
        }
        .fullScreenCover(isPresented: $showInfoPopup) {
            WordInShapesInfoView()
                .background(BackgroundClearView())
        }
        .alert("Exit Game?", isPresented: $showExitWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure? You may lose your progress if you exit.")
        }
        .onChange(of: soundEnabled) { newValue in
            // Sync sound setting with HTML game
            let soundValue = newValue ? "true" : "false"
            webView?.evaluateJavaScript("SOUND_ON = \(soundValue); document.getElementById('soundBtn').textContent = 'Sound: ' + (SOUND_ON ? 'On' : 'Off');") { _, error in
                if let error = error {
                    print("❌ Error updating sound: \(error)")
                }
            }
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()
        }
    }

    private func handleGameCompletion(score: Int, time: String) {
        // Mark as completed in daily puzzle manager (only for today's puzzle)
        if !archiveMode {
            dailyPuzzleManager.markCompleted(.wordInShapes)
        }

        // Record completion in statistics (for both today and archive)
        if let archiveDate = archiveDate {
            statisticsManager.recordCompletion(.wordInShapes, date: archiveDate)
        } else {
            statisticsManager.recordCompletion(.wordInShapes)
        }

        // Store score and time for alert
        gameScore = score
        gameTime = time

        // Show completion alert
        showCompletionAlert = true
    }
}

// UIViewRepresentable wrapper for WKWebView with JavaScript bridge
struct WebGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int, String) -> Void
    let onWebViewCreated: (WKWebView) -> Void
    let onTimeUpdate: (String) -> Void
    let onScoreUpdate: (Int) -> Void
    let onStreakUpdate: (Int) -> Void
    let onPenaltyUpdate: (Int) -> Void
    let onHintsUpdate: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            seed: seed,
            onGameCompleted: onGameCompleted,
            onTimeUpdate: onTimeUpdate,
            onScoreUpdate: onScoreUpdate,
            onStreakUpdate: onStreakUpdate,
            onPenaltyUpdate: onPenaltyUpdate,
            onHintsUpdate: onHintsUpdate
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.add(context.coordinator, name: "gameCompleted")
        configuration.userContentController.add(context.coordinator, name: "timeUpdate")
        configuration.userContentController.add(context.coordinator, name: "scoreUpdate")
        configuration.userContentController.add(context.coordinator, name: "streakUpdate")
        configuration.userContentController.add(context.coordinator, name: "penaltyUpdate")
        configuration.userContentController.add(context.coordinator, name: "hintsUpdate")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        // Call the callback with the created webView
        onWebViewCreated(webView)

        // Load the HTML file from bundle
        if let htmlPath = Bundle.main.path(forResource: "game", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Set navigation delegate to inject seed after page loads
            webView.navigationDelegate = context.coordinator

            // Load the HTML
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: game.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed - .id(seed) handles recreation on seed change
    }

    // Coordinator to handle JavaScript messages and navigation
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var seed: Int
        let onGameCompleted: (Int, String) -> Void
        let onTimeUpdate: (String) -> Void
        let onScoreUpdate: (Int) -> Void
        let onStreakUpdate: (Int) -> Void
        let onPenaltyUpdate: (Int) -> Void
        let onHintsUpdate: (Int) -> Void

        init(seed: Int, onGameCompleted: @escaping (Int, String) -> Void, onTimeUpdate: @escaping (String) -> Void, onScoreUpdate: @escaping (Int) -> Void, onStreakUpdate: @escaping (Int) -> Void, onPenaltyUpdate: @escaping (Int) -> Void, onHintsUpdate: @escaping (Int) -> Void) {
            self.seed = seed
            self.onGameCompleted = onGameCompleted
            self.onTimeUpdate = onTimeUpdate
            self.onScoreUpdate = onScoreUpdate
            self.onStreakUpdate = onStreakUpdate
            self.onPenaltyUpdate = onPenaltyUpdate
            self.onHintsUpdate = onHintsUpdate
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted",
               let body = message.body as? [String: Any],
               let score = body["score"] as? Int,
               let time = body["time"] as? String {

                print("✅ Game completed! Score: \(score), Time: \(time)")
                onGameCompleted(score, time)
            } else if message.name == "timeUpdate",
                      let time = message.body as? String {
                onTimeUpdate(time)
            } else if message.name == "scoreUpdate",
                      let score = message.body as? Int {
                onScoreUpdate(score)
            } else if message.name == "streakUpdate",
                      let streak = message.body as? Int {
                onStreakUpdate(streak)
            } else if message.name == "penaltyUpdate",
                      let penalty = message.body as? Int {
                onPenaltyUpdate(penalty)
            } else if message.name == "hintsUpdate",
                      let hints = message.body as? Int {
                onHintsUpdate(hints)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject iPad-specific CSS if on iPad
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad

            if isIPad {
                let iPadCSSScript = """
                (function() {
                    console.log('iPad detected, injecting large screen styles');
                    const style = document.createElement('style');
                    style.textContent = `
                        :root { --cell:38px !important; }
                        body { padding:12px !important; }
                        h1 { font-size: 32px !important; margin: 6px 0 !important; }
                        #hud { font-size:16px !important; gap:18px !important; margin: 8px 0 10px !important; }
                        .board { gap:5px !important; }
                        .cell { font-size:16px !important; border:1px solid #aaa !important; }
                        .controls { margin:12px 0 !important; gap:8px !important; }
                        button { padding:10px 20px !important; font-size:15px !important; border-radius:8px !important; }
                        .current { font-size:24px !important; min-height:28px !important; margin:6px 0 0 !important; }
                        .wordlist { gap:8px !important; width:min(380px,96vw) !important; }
                        .wordlist .row { padding:10px 12px !important; font-size:28px !important; border-radius:8px !important; gap:5px !important; }
                        .toast { font-size:18px !important; padding:14px 18px !important; }
                    `;
                    document.head.appendChild(style);
                    console.log('iPad styles injected successfully');
                })();
                """

                webView.evaluateJavaScript(iPadCSSScript) { _, error in
                    if let error = error {
                        print("❌ Error injecting iPad CSS: \(error)")
                    } else {
                        print("✅ iPad CSS injected")
                    }
                }
            }

            // Start game with seed
            let script = """
            if (window.setSeed && window.startDailyGame) {
                window.setSeed(\(seed));
                window.startDailyGame();
            }
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

// MARK: - Already Completed View

struct WordInShapesCompletedView: View {
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

                        Text("Great job! You've finished today's Word In Shapes puzzle.")
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
    WebWordInShapesGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
