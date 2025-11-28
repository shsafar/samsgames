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
                    // WebView for the game
                    WebDoubleBubbleGameViewRepresentable(
                        seed: seed,
                        onGameCompleted: archiveMode ? { _ in } : handleGameCompletion
                    )
                    .id(seed) // Force recreation when seed changes (new day)
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
        // Mark as completed in daily puzzle manager
        dailyPuzzleManager.markCompleted(.doubleBubble)

        // Record completion in statistics
        statisticsManager.recordCompletion(.doubleBubble)

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

// UIViewRepresentable wrapper for WKWebView with JavaScript bridge
struct WebDoubleBubbleGameViewRepresentable: UIViewRepresentable {
    let seed: Int
    let onGameCompleted: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(seed: seed, onGameCompleted: onGameCompleted)
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

        // Add message handler for game completion
        configuration.userContentController.add(context.coordinator, name: "gameCompleted")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true

        // Load the HTML file from bundle
        if let htmlPath = Bundle.main.path(forResource: "doublebubble", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)

            // Set navigation delegate to inject seed after page loads
            webView.navigationDelegate = context.coordinator

            // Load the HTML
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("❌ Error: doublebubble.html not found in bundle")
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed - .id(seed) handles recreation on seed change
    }

    // Coordinator to handle JavaScript messages and navigation
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var seed: Int
        let onGameCompleted: (Int) -> Void

        init(seed: Int, onGameCompleted: @escaping (Int) -> Void) {
            self.seed = seed
            self.onGameCompleted = onGameCompleted
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "gameCompleted",
               let body = message.body as? [String: Any],
               let score = body["score"] as? Int {

                print("✅ Game completed! Score: \\(score)")
                onGameCompleted(score)
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
