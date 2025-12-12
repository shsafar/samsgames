//
//  WebDiamondStackGameView.swift
//  Sam's Games
//
//  Diamond Stack game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebDiamondStackGameView: View {
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
            self.level = manager.getDiamondStackLevelForDate(archiveDate)
        } else {
            self.seed = manager.getSeedForToday()
            self.level = manager.getTodayDiamondStackLevel()
        }
    }

    var body: some View {
        Group {
            if showSplash {
                splashScreen
            } else {
                gameView
            }
        }
        .onAppear {
            dailyPuzzleManager.checkForNewDay()
            startSplashTimer()
        }
        .navigationBarHidden(true)
        .alert("Puzzle Completed!", isPresented: $showCompletionAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's Diamond Stack puzzle!")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .diamondStack)
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

    // MARK: - Subviews

    private var splashScreen: some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Try to load the custom icon, show SF Symbol if not found
                if let customIcon = GameType.diamondStack.customIcon,
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
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 120))
                        .foregroundColor(.yellow)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Text("Diamond Stack")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.orange)
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
            DiamondStackWebView(
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
        // Mark as completed in daily puzzle manager (only for today's puzzle)
        if !archiveMode {
            dailyPuzzleManager.markCompleted(.diamondStack)
        }

        // Record completion in statistics (for both today and archive)
        if let archiveDate = archiveDate {
            statisticsManager.recordCompletion(.diamondStack, date: archiveDate)
        } else {
            statisticsManager.recordCompletion(.diamondStack)
        }

        // Show completion alert after 2 seconds so user can see the result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCompletionAlert = true
        }
    }
}

// MARK: - WebView Wrapper

struct DiamondStackWebView: View {
    let seed: Int
    let level: Int
    let onComplete: () -> Void

    @State private var soundEnabled = true
    @State private var webView: WKWebView?
    @State private var gameTime: String = "0s"
    @State private var scoreCount: Int = 100
    @State private var hintsRemaining: Int = 3
    @State private var penaltyCount: Int = 0
    @State private var showQuickTips = false

    var body: some View {
        VStack(spacing: 0) {
            // Standardized button bar
            StandardGameButtonBar(
                onReset: {
                    resetGame()
                },
                onRevealHint: {
                    revealHint()
                },
                soundEnabled: $soundEnabled,
                resetLabel: "START/RESET",
                revealLabel: "REVEAL",
                showReveal: true
            )

            // Game title with info icon
            HStack(spacing: 8) {
                Text("Diamond Stack")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                // Info icon
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
                score: (value: scoreCount, label: "Score"),
                moves: nil,
                streak: nil,
                hints: hintsRemaining,
                penalty: (value: penaltyCount, label: "Penalty")
            )

            // WebView game
            WebDiamondStackGameViewRepresentable(
                seed: seed,
                level: level,
                onGameComplete: onComplete,
                webView: $webView,
                gameTime: $gameTime,
                scoreCount: $scoreCount,
                hintsRemaining: $hintsRemaining,
                penaltyCount: $penaltyCount
            )
        }
        .onChange(of: soundEnabled) { _, newValue in
            webView?.evaluateJavaScript("setSoundEnabled(\(newValue));")
        }
        .sheet(isPresented: $showQuickTips) {
            DiamondStackQuickTipsView()
        }
    }

    private func resetGame() {
        webView?.evaluateJavaScript("smartReset();") { _, error in
            if let error = error {
                print("❌ Reset error: \(error)")
            }
        }
    }

    private func revealHint() {
        webView?.evaluateJavaScript("revealOne();") { _, error in
            if let error = error {
                print("❌ Reveal error: \(error)")
            }
        }
    }
}

// MARK: - UIViewRepresentable wrapper for WKWebView
struct WebDiamondStackGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let level: Int
    let onGameComplete: () -> Void
    @Binding var webView: WKWebView?
    @Binding var gameTime: String
    @Binding var scoreCount: Int
    @Binding var hintsRemaining: Int
    @Binding var penaltyCount: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(
            self,
            onGameComplete: onGameComplete,
            webViewBinding: $webView,
            gameTime: $gameTime,
            scoreCount: $scoreCount,
            hintsRemaining: $hintsRemaining,
            penaltyCount: $penaltyCount
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Add message handler for game completion
        configuration.userContentController.add(context.coordinator, name: "gameComplete")

        // Add message handler for game stats
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

        // Store webView reference
        context.coordinator.webViewBinding.wrappedValue = webView

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

        // Load local diamondstack.html
        if let htmlPath = Bundle.main.path(forResource: "diamondstack", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("Loading Diamond Stack game from: \(htmlPath)")
        } else {
            print("Error: diamondstack.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebDiamondStackGameViewRepresentable
        var onGameComplete: () -> Void
        let webViewBinding: Binding<WKWebView?>
        let gameTime: Binding<String>
        let scoreCount: Binding<Int>
        let hintsRemaining: Binding<Int>
        let penaltyCount: Binding<Int>

        init(
            _ parent: WebDiamondStackGameViewRepresentable,
            onGameComplete: @escaping () -> Void,
            webViewBinding: Binding<WKWebView?>,
            gameTime: Binding<String>,
            scoreCount: Binding<Int>,
            hintsRemaining: Binding<Int>,
            penaltyCount: Binding<Int>
        ) {
            self.parent = parent
            self.onGameComplete = onGameComplete
            self.webViewBinding = webViewBinding
            self.gameTime = gameTime
            self.scoreCount = scoreCount
            self.hintsRemaining = hintsRemaining
            self.penaltyCount = penaltyCount
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
            print("Seed: \(parent.seed)")
            print("Level: \(parent.level)")

            // Set seed and level, then build board and auto-start
            let script = """
            console.log('Swift calling JavaScript...');
            if (window.setSeed && window.setLevel) {
                window.setSeed(\(parent.seed));
                console.log('Seed set to: \(parent.seed)');

                window.setLevel(\(parent.level));
                console.log('Level set to: \(parent.level)');

                // Rebuild board for new level and auto-start
                buildBoard();
                buildKeypad();
                autoStart();

                console.log('Diamond Stack started at level \(parent.level)');
            } else {
                console.error('setSeed or setLevel not available');
            }
            """

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error setting seed and level: \(error)")
                } else {
                    print("Diamond Stack initialized successfully")
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
                        if let score = stats["score"] as? Int {
                            self.scoreCount.wrappedValue = score
                        }
                        if let reveals = stats["reveals"] as? Int {
                            self.hintsRemaining.wrappedValue = reveals
                        }
                        if let penalty = stats["penalty"] as? Int {
                            self.penaltyCount.wrappedValue = penalty
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Quick Tips View
struct DiamondStackQuickTipsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Play")
                        .font(.system(size: 20, weight: .bold))

                    Text("Fill in the empty circles with numbers 1-9 so that:")
                        .padding(.top, 4)

                    Text("• Each number on the bottom matches the sum of the two numbers above it")
                    Text("• Use the number pad at the bottom to enter values")
                    Text("• The puzzle is complete when all circles are filled correctly")
                }
                .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Hints")
                        .font(.system(size: 20, weight: .bold))

                    Text("You are allowed a maximum of 3 hints per game.")
                        .padding(.top, 4)

                    Text("• Tap a circle to select it")
                    Text("• Press REVEAL to show the correct number for that circle")
                    Text("• Each hint costs 5 points")
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Diamond Stack")
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
    WebDiamondStackGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
