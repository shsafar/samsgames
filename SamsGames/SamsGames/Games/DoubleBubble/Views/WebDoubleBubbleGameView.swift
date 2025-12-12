//
//  WebDoubleBubbleGameView.swift
//  Sam's Games
//
//  Double Bubble game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebDoubleBubbleGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss

    @State private var showCompletionAlert = false
    @State private var gameScore: Int = 0
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var splashScale: CGFloat = 0.5
    @State private var splashOpacity: Double = 0.0
    @State private var showExitWarning = false

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
        return dailyPuzzleManager.isCompletedToday(.doubleBubble)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button and help button
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
                .background(Color(UIColor.systemBackground))

                // Show either completed screen or game
                if isAlreadyCompleted {
                    AlreadyCompletedView()
                } else {
                    // Game with standard controls
                    DoubleBubbleGameContent(
                        seed: seed,
                        archiveMode: archiveMode,
                        onGameCompleted: archiveMode ? { _ in } : handleGameCompletion
                    )
                }
            }

            // Splash screen overlay (only if not already completed)
            if showSplash && !isAlreadyCompleted {
                ZStack {
                    // Teal gradient background
                    LinearGradient(
                        colors: [
                            Color(red: 0.56, green: 0.9, blue: 0.9),
                            Color(red: 0.3, green: 0.72, blue: 0.72)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // DB Icon with animation
                    Image("dbicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(splashScale)
                        .opacity(splashOpacity)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Double Bubble puzzle!\\n\\nScore: \\(gameScore)")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .doubleBubble)
        }
        .alert("Exit Game?", isPresented: $showExitWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure? You may lose your progress if you exit.")
        }
        .onAppear {
            // Check if new day when view appears
            dailyPuzzleManager.checkForNewDay()

            // Animate splash screen (only if not already completed)
            if !isAlreadyCompleted {
                withAnimation(.easeOut(duration: 0.6)) {
                    splashScale = 1.0
                    splashOpacity = 1.0
                }

                // Hide splash screen after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeIn(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }
        }
    }

    private func handleGameCompletion(score: Int) {
        // Mark as completed in daily puzzle manager (only for today's puzzle)
        if !archiveMode {
            dailyPuzzleManager.markCompleted(.doubleBubble)
        }

        // Record completion in statistics (for both today and archive)
        if let archiveDate = archiveDate {
            statisticsManager.recordCompletion(.doubleBubble, date: archiveDate)
        } else {
            statisticsManager.recordCompletion(.doubleBubble)
        }

        // Store score for alert
        gameScore = score

        // Show completion alert
        showCompletionAlert = true
    }
}

// MARK: - Already Completed View
struct AlreadyCompletedView: View {
    @State private var timeUntilNext = ""

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Teal gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.56, green: 0.9, blue: 0.9),
                    Color(red: 0.3, green: 0.72, blue: 0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Icon
                Image("dbicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                // Completed message
                VStack(spacing: 12) {
                    Text("Puzzle Completed!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Great job! You've finished today's Double Bubble puzzle.")
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

// MARK: - Double Bubble Game Content with Standard Controls

struct DoubleBubbleGameContent: View {
    let seed: Int
    let archiveMode: Bool
    let onGameCompleted: (Int) -> Void

    @State private var soundEnabled = true
    @State private var webView: WKWebView?
    @State private var showGameInfo = false
    @State private var gameTime: String = "0:00"
    @State private var scoreCount: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Standard button bar
            StandardGameButtonBar(
                onReset: {
                    webView?.evaluateJavaScript("restartGame(); startGame();")
                },
                onRevealHint: nil,
                soundEnabled: $soundEnabled,
                resetLabel: "START/RESET",
                showReveal: false
            )

            // Game title with info icon
            HStack(spacing: 8) {
                Text("Double Bubble")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Button(action: { showGameInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 12)

            // Standard game info bar
            StandardGameInfoBar(
                time: gameTime,
                score: (scoreCount, "Score"),
                moves: nil,
                streak: nil,
                hints: nil,
                penalty: nil
            )

            // WebView game
            WebDoubleBubbleGameViewRepresentable(
                seed: seed,
                onGameCompleted: onGameCompleted,
                webView: $webView,
                gameTime: $gameTime,
                scoreCount: $scoreCount
            )
        }
        .onChange(of: soundEnabled) { _, newValue in
            webView?.evaluateJavaScript("if (typeof setSoundEnabled === 'function') { setSoundEnabled(\(newValue)); }")
        }
        .alert("How to Play", isPresented: $showGameInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Tap two bubbles to create fragments. Fragments auto-merge into words.")
        }
    }
}

// UIViewRepresentable wrapper for WKWebView with JavaScript bridge
struct WebDoubleBubbleGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int) -> Void
    @Binding var webView: WKWebView?
    @Binding var gameTime: String
    @Binding var scoreCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(seed: seed, onGameCompleted: onGameCompleted, gameTime: $gameTime, scoreCount: $scoreCount)
    }

    func makeUIView(context: Context) -> WKWebView {
        // Clear ALL WebView data first to ensure fresh game
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) { }

        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Inject script to set waitingForSeed flag BEFORE page loads
        let waitingScript = WKUserScript(
            source: "window.waitingForSeed = true;",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(waitingScript)

        // Add message handlers
        configuration.userContentController.add(context.coordinator, name: "gameCompleted")
        configuration.userContentController.add(context.coordinator, name: "gameStats")

        let newWebView = WKWebView(frame: .zero, configuration: configuration)
        newWebView.backgroundColor = .systemBackground
        newWebView.isOpaque = false
        newWebView.scrollView.isScrollEnabled = true
        newWebView.scrollView.bounces = true

        // Store in binding
        DispatchQueue.main.async {
            self.webView = newWebView
        }

        // Load the HTML file from bundle
        if let htmlPath = Bundle.main.path(forResource: "doublebubble", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Set navigation delegate to inject seed after page loads
            newWebView.navigationDelegate = context.coordinator

            // Load the HTML
            newWebView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: doublebubble.html not found in bundle")
        }

        return newWebView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed - .id(seed) handles recreation on seed change
    }

    // Coordinator to handle JavaScript messages and navigation
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var seed: Int
        let onGameCompleted: (Int) -> Void
        @Binding var gameTime: String
        @Binding var scoreCount: Int

        init(seed: Int, onGameCompleted: @escaping (Int) -> Void, gameTime: Binding<String>, scoreCount: Binding<Int>) {
            self.seed = seed
            self.onGameCompleted = onGameCompleted
            self._gameTime = gameTime
            self._scoreCount = scoreCount
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted",
               let body = message.body as? [String: Any],
               let score = body["score"] as? Int {

                print("✅ Game completed! Score: \\(score)")
                onGameCompleted(score)
            } else if message.name == "gameStats",
                      let stats = message.body as? [String: Any] {
                DispatchQueue.main.async {
                    // Update time
                    if let time = stats["time"] as? String {
                        self.gameTime = time
                    }
                    // Update score
                    if let score = stats["score"] as? Int {
                        self.scoreCount = score
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject the seed after the page loads, then start the game
            let script = """
            if (window.setSeed && window.startDailyGame) {
                // AGGRESSIVE RESET
                localStorage.clear();
                sessionStorage.clear();

                // Set the correct daily seed
                window.setSeed(\\(seed));

                // Start daily game
                window.startDailyGame();
            }
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

#Preview {
    WebDoubleBubbleGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
