//
//  WebWaterTableGameView.swift
//  Sam's Games
//
//  WaterTable game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebWaterTableGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var isPulsing = false
    @State private var showExitWarning = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Check if already completed today (only for non-archive mode)
    private var isAlreadyCompleted: Bool {
        if archiveMode {
            return false // Archive mode always allows play
        }
        return dailyPuzzleManager.isCompletedToday(.waterTable)
    }

    // Calculate seed and level
    private let seed: Int
    private let level: Int

    init(archiveMode: Bool = false, archiveDate: Date? = nil, archiveSeed: Int? = nil) {
        self.archiveMode = archiveMode
        self.archiveDate = archiveDate
        self.archiveSeed = archiveSeed

        let manager = DailyPuzzleManager()
        if let archiveSeed = archiveSeed, let archiveDate = archiveDate {
            self.seed = archiveSeed
            self.level = manager.getWaterTableLevelForDate(archiveDate)
        } else {
            self.seed = manager.getSeedForToday()
            self.level = manager.getTodayWaterTableLevel()
        }
    }

    var body: some View {
        Group {
            if isAlreadyCompleted {
                // Show completion screen if already completed today
                WaterTableCompletedView()
            } else if showSplash {
                splashScreen
            } else {
                gameView
            }
        }
        .onAppear {
            dailyPuzzleManager.checkForNewDay()
            if !isAlreadyCompleted {
                startSplashTimer()
            }
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                // Alert dismissed, completion screen will show automatically
            }
        } message: {
            Text("Great job! You completed today's WaterTable puzzle!")
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
            GameInstructionsView(gameType: .waterTable)
        }
    }

    // MARK: - Subviews

    private var splashScreen: some View {
        ZStack {
            // Ocean blue gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.95, blue: 1.0),
                    Color(red: 0.7, green: 0.85, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Try to load the custom icon, show SF Symbol if not found
                if let customIcon = GameType.waterTable.customIcon,
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
                    Image(systemName: "drop.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.blue)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Text("WaterTable")
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

    private var gameView: some View {
        NavigationView {
            WaterTableWebView(
                seed: seed,
                level: level,
                onComplete: {
                    handleGameCompletion()
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
    }

    private func startSplashTimer() {
        // Show splash for 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showSplash = false
            }
        }
    }

    private func handleGameCompletion() {
        if archiveMode {
            // Record completion for the specific archive date
            if let date = archiveDate {
                statisticsManager.recordCompletion(.waterTable, date: date)
            }
        } else {
            // Mark as completed in daily puzzle manager (today's puzzle)
            dailyPuzzleManager.markCompleted(.waterTable)

            // Record completion in statistics for today
            statisticsManager.recordCompletion(.waterTable)
        }

        // Show completion alert after 2 seconds so user can see the result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCompletionAlert = true
        }
    }
}

// MARK: - WebView Wrapper

struct WaterTableWebView: View {
    let seed: Int
    let level: Int
    let onComplete: () -> Void

    @State private var soundEnabled = true
    @State private var webView: WKWebView?
    @State private var showQuickTips = false
    @State private var gameTime: String = "0.0s"
    @State private var piecesCount: Int = 0
    @State private var scoreCount: Int = 0
    @State private var comboCount: Int = 0

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
                showReveal: true
            )

            // Game title with special instructions icon
            HStack(spacing: 8) {
                Text("WaterTable")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                // Special instructions (i) icon - blue for WaterTable (has special tips)
                Button(action: {
                    showQuickTips = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 12)

            // Standardized game info bar
            StandardGameInfoBar(
                time: gameTime,
                score: (piecesCount, "Pieces"),
                moves: scoreCount,  // Using moves field for score display
                streak: comboCount,  // Combo
                hints: nil,     // Inactive (gray)
                penalty: nil    // Inactive (gray)
            )

            // WebView game
            WebWaterTableGameViewRepresentable(
                seed: seed,
                level: level,
                onGameComplete: onComplete,
                webView: $webView,
                gameTime: $gameTime,
                piecesCount: $piecesCount,
                scoreCount: $scoreCount,
                comboCount: $comboCount
            )
        }
        .onChange(of: soundEnabled) { _, newValue in
            webView?.evaluateJavaScript("setSoundEnabled(\(newValue));")
        }
        .sheet(isPresented: $showQuickTips) {
            WaterTableQuickTipsView()
        }
    }

    private func breakPins() {
        webView?.evaluateJavaScript("if (typeof breakPins === 'function') { breakPins(); }") { _, error in
            if let error = error {
                print("❌ Break error: \(error)")
            }
        }
    }

    private func resetGame() {
        print("🔄 Reset button pressed - calling resetGame()")
        webView?.evaluateJavaScript("resetGame();") { _, error in
            if let error = error {
                print("❌ Reset Game error: \(error)")
            } else {
                print("✅ Reset Game succeeded")
            }
        }
    }

    private func revealSolution() {
        webView?.evaluateJavaScript("if (typeof revealSolution === 'function') { revealSolution(); }") { _, error in
            if let error = error {
                print("❌ Reveal error: \(error)")
            }
        }
    }
}

// MARK: - WebView UIViewRepresentable

struct WebWaterTableGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let level: Int
    let onGameComplete: () -> Void
    @Binding var webView: WKWebView?
    @Binding var gameTime: String
    @Binding var piecesCount: Int
    @Binding var scoreCount: Int
    @Binding var comboCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            self,
            onGameComplete: onGameComplete,
            webViewBinding: $webView,
            gameTime: $gameTime,
            piecesCount: $piecesCount,
            scoreCount: $scoreCount,
            comboCount: $comboCount
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Add message handlers for game completion and stats
        configuration.userContentController.add(context.coordinator, name: "gameComplete")
        configuration.userContentController.add(context.coordinator, name: "gameStats")

        // Enable console logging
        let consoleScript = WKUserScript(
            source: """
            (function() {
                var originalLog = console.log;
                var originalError = console.error;

                console.log = function() {
                    var args = Array.prototype.slice.call(arguments);
                    var message = args.map(function(arg) {
                        if (typeof arg === 'object') {
                            try { return JSON.stringify(arg); }
                            catch(e) { return String(arg); }
                        }
                        return String(arg);
                    }).join(' ');
                    window.webkit.messageHandlers.logging.postMessage("LOG: " + message);
                };

                console.error = function() {
                    var args = Array.prototype.slice.call(arguments);
                    var message = args.map(function(arg) { return String(arg); }).join(' ');
                    window.webkit.messageHandlers.logging.postMessage("ERROR: " + message);
                };
            })();
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(consoleScript)
        configuration.userContentController.add(context.coordinator, name: "logging")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false

        // Completely disable all scrolling
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        // Disable zooming
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bouncesZoom = false

        // Set navigation delegate
        webView.navigationDelegate = context.coordinator

        // Store webView reference via coordinator
        context.coordinator.webViewBinding.wrappedValue = webView

        // Load local watertable.html
        if let htmlPath = Bundle.main.path(forResource: "watertable", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("Loading WaterTable game from: \(htmlPath)")
        } else {
            print("Error: watertable.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebWaterTableGameViewRepresentable
        var onGameComplete: () -> Void
        let webViewBinding: Binding<WKWebView?>
        let gameTime: Binding<String>
        let piecesCount: Binding<Int>
        let scoreCount: Binding<Int>
        let comboCount: Binding<Int>

        init(_ parent: WebWaterTableGameViewRepresentable,
             onGameComplete: @escaping () -> Void,
             webViewBinding: Binding<WKWebView?>,
             gameTime: Binding<String>,
             piecesCount: Binding<Int>,
             scoreCount: Binding<Int>,
             comboCount: Binding<Int>) {
            self.parent = parent
            self.onGameComplete = onGameComplete
            self.webViewBinding = webViewBinding
            self.gameTime = gameTime
            self.piecesCount = piecesCount
            self.scoreCount = scoreCount
            self.comboCount = comboCount
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
            print("Seed: \(parent.seed)")
            print("Level: \(parent.level)")

            // Set seed and level, enable daily mode, then start the game
            let script = """
            console.log('Swift calling JavaScript...');
            if (window.setSeed && window.setLevel && window.enableDailyMode && window.initGame) {
                window.setSeed(\(parent.seed));
                console.log('Seed set to: \(parent.seed)');

                window.setLevel(\(parent.level));
                console.log('Level set to: \(parent.level)');

                window.enableDailyMode();
                console.log('Daily mode enabled');

                window.initGame();
                console.log('WaterTable started at level \(parent.level)');
            } else {
                console.error('setSeed, setLevel, enableDailyMode, or initGame not available');
            }
            """

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error setting seed and level: \(error)")
                } else {
                    print("WaterTable initialized successfully")
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed to load: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("WebView provisional navigation failed: \(error.localizedDescription)")
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "logging" {
                print("JS: \(message.body)")
            } else if message.name == "gameComplete" {
                if let dict = message.body as? [String: Any],
                   let won = dict["won"] as? Bool,
                   won {
                    print("Game completed successfully!")
                    DispatchQueue.main.async {
                        self.onGameComplete()
                    }
                }
            } else if message.name == "gameStats" {
                if let stats = message.body as? [String: Any] {
                    DispatchQueue.main.async {
                        if let time = stats["time"] as? String {
                            self.gameTime.wrappedValue = time
                        }
                        if let pieces = stats["pieces"] as? Int {
                            self.piecesCount.wrappedValue = pieces
                        }
                        if let score = stats["score"] as? Int {
                            self.scoreCount.wrappedValue = score
                        }
                        if let combo = stats["combo"] as? Int {
                            self.comboCount.wrappedValue = combo
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Already Completed View

struct WaterTableCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timeUntilNext = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Ocean blue gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.blue.opacity(0.8)
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

                        Text("Great job! You've finished today's WaterTable puzzle.")
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

// MARK: - Quick Tips View

struct WaterTableQuickTipsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Play")
                        .font(.title2.bold())
                        .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Tap **Break** to shatter pins. Drag pieces from water onto shafts.")
                            .font(.body)

                        Text("2. Match the **hidden water depth**. Shafts turn **green** and spray when correct.")
                            .font(.body)

                        Text("+10 per correct piece, combo bonus, –5 per Reveal / decoy / Show Targets.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WebWaterTableGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
