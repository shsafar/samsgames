//
//  WebDiskBreakGameView.swift
//  Sam's Games
//
//  DiskBreak game integrated with daily puzzle system
//

import SwiftUI
import WebKit

struct WebDiskBreakGameView: View {
    @EnvironmentObject var dailyPuzzleManager: DailyPuzzleManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showCompletionAlert = false
    @State private var showInstructions = false
    @State private var showSplash = true
    @State private var isPulsing = false

    // Archive mode support
    var archiveMode: Bool = false
    var archiveDate: Date? = nil
    var archiveSeed: Int? = nil

    // Check if already completed today (only for non-archive mode)
    private var isAlreadyCompleted: Bool {
        // TESTING: Temporarily disabled to allow testing
        return false

        // PRODUCTION: Uncomment the code below when done testing
        /*
        if archiveMode {
            return false // Archive mode always allows play
        }
        return dailyPuzzleManager.isCompletedToday(.diskBreak)
        */
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
            self.level = manager.getDiskBreakLevelForDate(archiveDate)
        } else {
            self.seed = manager.getSeedForToday()
            self.level = manager.getTodayDiskBreakLevel()
        }
    }

    var body: some View {
        Group {
            if isAlreadyCompleted {
                // Show completion screen if already completed today
                DiskBreakCompletedView()
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
                dismiss()
            }
        } message: {
            Text("Great job! You completed today's DiskBreak puzzle!")
        }
        .sheet(isPresented: $showInstructions) {
            GameInstructionsView(gameType: .diskBreak)
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
                if let customIcon = GameType.diskBreak.customIcon,
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
                    Image(systemName: "circle.grid.cross")
                        .font(.system(size: 120))
                        .foregroundColor(.cyan)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                }

                Text("DiskBreak")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.cyan)
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
        VStack(spacing: 0) {
            // Top bar with back button
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.blue)
                }

                Spacer()

                Button(action: { showInstructions = true }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color(UIColor.systemBackground))

            // WebView for the game
            WebDiskBreakGameViewRepresentable(
                seed: seed,
                level: level,
                onGameComplete: {
                    handleGameCompletion()
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.systemGroupedBackground))
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
        // Only mark as completed if not in archive mode
        if !archiveMode {
            // Mark as completed in daily puzzle manager
            dailyPuzzleManager.markCompleted(.diskBreak)

            // Record completion in statistics
            statisticsManager.recordCompletion(.diskBreak)
        }

        // Show completion alert after 2 seconds so user can see the result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showCompletionAlert = true
        }
    }
}

// UIViewRepresentable wrapper for WKWebView
struct WebDiskBreakGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let level: Int
    let onGameComplete: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onGameComplete: onGameComplete)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Use modern API for JavaScript (iOS 14+)
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        // Add message handler for game completion
        configuration.userContentController.add(context.coordinator, name: "gameComplete")

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

        // Load local diskbreak.html
        if let htmlPath = Bundle.main.path(forResource: "diskbreak", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            print("Loading DiskBreak game from: \(htmlPath)")
        } else {
            print("Error: diskbreak.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebDiskBreakGameViewRepresentable
        var onGameComplete: () -> Void

        init(_ parent: WebDiskBreakGameViewRepresentable, onGameComplete: @escaping () -> Void) {
            self.parent = parent
            self.onGameComplete = onGameComplete
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
            print("Seed: \(parent.seed)")
            print("Level: \(parent.level)")

            // Set seed and level, then select level to start the game
            let script = """
            console.log('Swift calling JavaScript...');
            if (window.setSeed && window.selectLevel) {
                window.setSeed(\(parent.seed));
                console.log('Seed set to: \(parent.seed)');

                window.selectLevel(\(parent.level));
                console.log('Level selected: \(parent.level)');

                console.log('DiskBreak started at level \(parent.level)');
            } else {
                console.error('setSeed or selectLevel not available');
            }
            """

            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("Error setting seed and level: \(error)")
                } else {
                    print("DiskBreak initialized successfully")
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
            }
        }
    }
}

// MARK: - Already Completed View

struct DiskBreakCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var timeUntilNext = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Cyan gradient background
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.6),
                    Color.cyan.opacity(0.8)
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

                        Text("Great job! You've finished today's DiskBreak puzzle.")
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
    WebDiskBreakGameView()
        .environmentObject(DailyPuzzleManager())
        .environmentObject(StatisticsManager())
}
